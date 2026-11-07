import XCTest
@testable import PawTrustCore

final class PrivacyAndAccessTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_780_272_000) // 2026-06-01 UTC-ish

    func testExtractorKeepsWhitelistAndDropsIdentifiers() {
        let lines = [
            "犬名：豆豆",
            "品种：贵宾",
            "性别：母",
            "体型：小型",
            "出生日期：2020年3月2日",
            "主人姓名：合成主人甲",
            "犬证号：SYN000",
            "芯片号：CHIP000",
            "联系电话：00011122233",
            "住址：合成路零号",
        ]
        let draft = LicenseExtractor.extract(lines: lines, now: now)
        let labels = Set(Mirror(reflecting: draft).children.compactMap(\.label))
        XCTAssertEqual(labels, ["dogName", "breed", "sex", "ageBand", "size"])
        XCTAssertEqual(draft.dogName.value, "豆豆")
        XCTAssertEqual(draft.breed.value, "贵宾")
        XCTAssertEqual(draft.sex.value, "母")
        XCTAssertEqual(draft.size.value, "小型")
        XCTAssertEqual(draft.ageBand.value, "成年")
        XCTAssertEqual(draft.dogName.origin, .systemInferred)

        let profile = draft.asProfile()
        XCTAssertFalse(profile.learningEnabled)
        let data = try! JSONEncoder().encode(profile)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertFalse(json.contains("合成主人甲"))
        XCTAssertFalse(json.contains("SYN000"))
        XCTAssertFalse(json.contains("CHIP000"))
        XCTAssertFalse(json.contains("00011122233"))
        XCTAssertFalse(json.contains("合成路零号"))
        XCTAssertFalse(json.contains("2020"))
        XCTAssertFalse(json.contains("4岁"))
        XCTAssertTrue(json.contains("豆豆"))
        XCTAssertTrue(json.contains("成年"))
        let object = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        let allowed: Set<String> = [
            "dogName", "breed", "sex", "ageBand", "size", "temperament", "sociability", "outing", "learningEnabled",
        ]
        XCTAssertTrue(Set(object.keys).isSubset(of: allowed))
    }

    func testWordsOnAPageDoNotUnlockAndUnavailableFailsClosed() {
        XCTAssertEqual(UnavailableDogLicenseVerifier().evaluate(), .unavailable)
        XCTAssertEqual(AccessController.afterProfileSaved(), .locked(.profileSavedAwaitingVerification))
        XCTAssertEqual(
            AccessController.afterVerification(.unavailable, hasProfile: true),
            .locked(.verifierUnavailable)
        )
        XCTAssertEqual(
            AccessController.afterVerification(.rejected, hasProfile: true),
            .locked(.verifierRejected)
        )
        let storedDocument = VerifierReceipt(issuer: "测试签发方", recordsDocument: true)
        XCTAssertEqual(
            AccessController.afterVerification(.accepted(storedDocument), hasProfile: true),
            .locked(.verifierRejected)
        )
        let clean = VerifierReceipt(issuer: "测试签发方", recordsDocument: false)
        XCTAssertEqual(
            AccessController.afterVerification(.accepted(clean), hasProfile: true),
            .verified(clean)
        )
        XCTAssertEqual(
            AccessController.afterVerification(.accepted(clean), hasProfile: false),
            .locked(.needsLocalProfile)
        )
        XCTAssertEqual(
            AccessController.afterExplicitDemo(channel: .release, hasProfile: true),
            .locked(.profileSavedAwaitingVerification)
        )
        XCTAssertEqual(
            AccessController.afterExplicitDemo(channel: .debug, hasProfile: true),
            .demo(DemoCopy.demoBanner)
        )
        XCTAssertEqual(
            AccessController.resolvingLaunch(channel: .release, hasProfile: true, storedDemoFlag: true),
            .locked(.profileSavedAwaitingVerification)
        )
        XCTAssertEqual(
            AccessController.resolvingLaunch(channel: .debug, hasProfile: true, storedDemoFlag: true),
            .demo(DemoCopy.demoBanner)
        )
        XCTAssertFalse(AccessController.afterProfileSaved().showsMap)
        XCTAssertTrue(AccessController.afterExplicitDemo(channel: .debug, hasProfile: true).showsMap)
    }

    func testLearningDoesNotOverwriteUserInputOrRunWhenDisabled() throws {
        var profile = DogProfile.empty
        profile.learningEnabled = false
        let unchanged = ProfileLearning.apply(
            search: QueryContext(topics: [.largeDog], nearMe: true, category: .walking),
            to: profile
        )
        XCTAssertNil(unchanged.size.value)
        profile.learningEnabled = true
        profile.size = Attributed(value: "小型", origin: .userEntered)
        let kept = ProfileLearning.apply(search: QueryContext(topics: [.largeDog]), to: profile)
        XCTAssertEqual(kept.size.value, "小型")
        XCTAssertEqual(kept.size.origin, .userEntered)
        profile.size = .empty
        let inferred = ProfileLearning.apply(search: QueryContext(topics: [.largeDog]), to: profile)
        XCTAssertEqual(inferred.size.value, "大型")
        XCTAssertEqual(inferred.size.origin, .systemInferred)
        let cleared = inferred.settingLearning(false)
        XCTAssertNil(cleared.size.value)
        XCTAssertFalse(cleared.learningEnabled)
    }

    func testLocalParserAndUnknownRules() {
        var state = ExploreState.initial()
        state = ExploreLogic.applyingComposer(state, text: "深圳 能带大狗进室内的餐厅")
        XCTAssertEqual(state.cityFilter, .shenzhen)
        XCTAssertEqual(state.categoryFilter, .dining)
        XCTAssertEqual(state.requiredTopics, [.indoor, .largeDog])
        XCTAssertEqual(state.interpreterLabel, "本地解析")
        XCTAssertFalse(state.interpreterLabel.localizedCaseInsensitiveContains("llm"))
        XCTAssertTrue(state.unmatchedTerms.isEmpty)
        let visible = ExploreLogic.visiblePlaces(state)
        XCTAssertEqual(visible.map(\.id), ["sz-mixc-dining"])
        XCTAssertTrue(ExploreLogic.unknownPlaceIDs(state).contains("sz-mixc-dining"))
        XCTAssertEqual(ExploreLogic.peekSummary(state).title, "没有已确认符合的地点")
        let lines = ExploreLogic.assessment(for: visible[0], state: state)?.lines.joined() ?? ""
        XCTAssertTrue(lines.contains(MatchCopy.unknownNotSatisfied))

        state = ExploreLogic.applyingComposer(state, text: "改成上海")
        XCTAssertEqual(state.cityFilter, .shanghai)
        XCTAssertEqual(state.categoryFilter, .dining)
        XCTAssertEqual(state.requiredTopics, [.indoor, .largeDog])
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).map(\.id), ["deda"])

        state = ExploreLogic.applyingComposer(state, text: "附近有围栏的遛狗地")
        XCTAssertNil(state.cityFilter)
        XCTAssertEqual(state.categoryFilter, .walking)
        XCTAssertTrue(state.nearMe)
        XCTAssertEqual(state.requiredTopics, [.fencedArea])
        XCTAssertTrue(ExploreLogic.peekSummary(state).title.contains("没有已确认符合"))

        state = ExploreLogic.applyingComposer(state, text: "人民公园")
        XCTAssertEqual(state.cityFilter, .shanghai)
        XCTAssertTrue(state.requiredTopics.isEmpty)
        XCTAssertTrue(ExploreLogic.visiblePlaces(state).contains { $0.id == "renmin" })

        state = ExploreLogic.applyingComposer(ExploreState.initial(), text: "滨江")
        XCTAssertTrue(ExploreLogic.visiblePlaces(state).contains { $0.id == "binjiang" })
        XCTAssertFalse(ExploreLogic.visiblePlaces(state).contains { $0.id == "fuxing" })
    }

    func testConfirmedRuleMatchesAndStatedDoesNot() {
        let confirmed = Place(
            id: "lab",
            name: "测试室内餐厅",
            district: "测试",
            kindLabel: "餐饮",
            latitude: 22.52,
            longitude: 114.0,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-fuxing",
            exampleDistanceMeters: 100,
            blurb: "测试数据，不是真实准入。",
            city: .shenzhen,
            category: .dining,
            accessRules: [
                AccessRule(
                    topic: .indoor,
                    value: .confirmedAllowed,
                    condition: "仅大厅",
                    source: "测试签发",
                    lastConfirmedAt: now
                ),
                AccessRule(topic: .largeDog, value: .statedAllowed, condition: "有人说过", source: "测试"),
            ]
        )
        var state = ExploreState.initial(places: [confirmed])
        state.cityFilter = .shenzhen
        state.categoryFilter = .dining
        state.requiredTopics = [.indoor]
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).map(\.id), ["lab"])
        XCTAssertTrue(ExploreLogic.unknownPlaceIDs(state).isEmpty)
        state.requiredTopics = [.indoor, .largeDog]
        XCTAssertTrue(ExploreLogic.unknownPlaceIDs(state).contains("lab"))
        let withoutDate = AccessRule(topic: .indoor, value: .confirmedAllowed, condition: "", source: "测试", lastConfirmedAt: nil)
        let undated = Place(
            id: "undated",
            name: "测试无日期",
            district: "测试",
            kindLabel: "餐饮",
            latitude: 22.52,
            longitude: 114.0,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-fuxing",
            exampleDistanceMeters: 100,
            blurb: "未核实",
            city: .shenzhen,
            category: .dining,
            accessRules: [withoutDate]
        )
        let assessment = RuleMatcher.assess(place: undated, topics: [.indoor])
        XCTAssertEqual(assessment.bucket, .unknown)
        XCTAssertTrue(assessment.lines.joined().contains(MatchCopy.missingTime))
    }

    func testFeedbackOrganizerDoesNotStoreAWeekdayOrConfirmARule() {
        let draft = FeedbackOrganizer.organize(
            "周六去了复兴公园，有围栏，能不能放绳我不确定。每家店另外算。",
            knownPlaceNames: SampleCatalog.places.map(\.name)
        )
        XCTAssertEqual(draft.placeNameHint, "复兴公园")
        XCTAssertEqual(draft.topic, .fencedArea)
        XCTAssertEqual(draft.observation, .observerSaysYes)
        XCTAssertNil(draft.observedDay)
        XCTAssertTrue(draft.condition.contains("每一家") || draft.condition.contains("店铺"))
        let dated = FeedbackOrganizer.organize("2026年5月1日围栏情况不确定。")
        XCTAssertEqual(dated.observedDay, "2026-05-01")
        XCTAssertEqual(dated.observation, .observerUnsure)
        let encoded = try! JSONEncoder().encode(
            LocalContribution(
                kind: "fieldNote",
                placeName: "复兴公园",
                topic: draft.topic?.rawValue,
                observation: draft.observation.rawValue,
                condition: draft.condition,
                observedDay: dated.observedDay
            )
        )
        let json = String(data: encoded, encoding: .utf8)!
        XCTAssertFalse(json.contains("confirmedAllowed"))
        XCTAssertFalse(json.contains("犬证号"))
        XCTAssertFalse(json.contains("周六"))
    }

    func testThrottleIsALocalIntervalNotASecurityClaim() {
        let first = Date(timeIntervalSince1970: 1_000)
        XCTAssertTrue(ContributionThrottle.allow(now: first, last: nil))
        XCTAssertFalse(ContributionThrottle.allow(now: first.addingTimeInterval(5), last: first))
        XCTAssertTrue(ContributionThrottle.allow(now: first.addingTimeInterval(15), last: first))
        XCTAssertTrue(ContributionThrottle.notice.contains("不是安全防护"))
        let items = (0..<40).map { LocalContribution(id: "\($0)", kind: "addPlace", placeName: "草稿\($0)") }
        var stored: [LocalContribution] = []
        for item in items {
            stored = ContributionThrottle.appending(item, to: stored)
        }
        XCTAssertEqual(stored.count, 30)
        XCTAssertEqual(stored.first?.id, "10")
    }

    func testProductionSourcesDoNotExportOrStoreSensitiveMaterial() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("README.md").path))
        let sources = try swiftFiles(under: root.appendingPathComponent("PawTrust"))
            + swiftFiles(under: root.appendingPathComponent("Packages/PawTrustCore/Sources"))
        XCTAssertFalse(sources.isEmpty)
        let allowedKeys: Set<String> = [
            StorageKey.favorites, StorageKey.profile, StorageKey.contributions, StorageKey.demoAccess,
        ]
        let bannedAPIs = ["URLSession", "UIImageWriteToSavedPhotosAlbum", "CryptoKit", "SHA256", "CC_SHA", "NSLog(", "Logger(", "print("]
        var findings: [String] = []
        let keyPattern = try NSRegularExpression(pattern: #"pawtrust\.[a-z0-9.\-]+"#)
        for url in sources {
            let text = try String(contentsOf: url, encoding: .utf8)
            for api in bannedAPIs where text.contains(api) {
                findings.append("\(url.lastPathComponent) contains \(api)")
            }
            let range = NSRange(text.startIndex..., in: text)
            for match in keyPattern.matches(in: text, range: range) {
                guard let slice = Range(match.range, in: text) else { continue }
                let key = String(text[slice])
                if !allowedKeys.contains(key) {
                    findings.append("\(url.lastPathComponent) key \(key)")
                }
            }
            for line in text.split(separator: "\n") where line.contains("UserDefaults") {
                let lowered = line.lowercased()
                if lowered.contains("image") || lowered.contains("ocr") || line.contains("证件") {
                    findings.append("\(url.lastPathComponent) defaults line \(line)")
                }
            }
        }
        XCTAssertEqual(findings, [])
    }

    private func swiftFiles(under directory: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        return enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }
}

private extension QueryContext {
    init(topics: [RuleTopic], nearMe: Bool = false, category: PlaceCategory? = nil) {
        self.init(city: nil, category: category, topics: topics, nearMe: nearMe)
    }
}
