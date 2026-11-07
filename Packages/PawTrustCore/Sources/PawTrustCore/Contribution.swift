import Foundation

public enum Observation: String, Codable, Equatable, Sendable {
    case unknown
    case observerSaysYes
    case observerSaysNo
    case observerUnsure
}

public struct ContributionDraft: Equatable, Sendable {
    public var placeNameHint: String?
    public var topic: RuleTopic?
    public var observation: Observation
    public var condition: String
    public var observedDay: String?
    public var note: String

    public init(
        placeNameHint: String? = nil,
        topic: RuleTopic? = nil,
        observation: Observation = .unknown,
        condition: String = "",
        observedDay: String? = nil,
        note: String = ""
    ) {
        self.placeNameHint = placeNameHint
        self.topic = topic
        self.observation = observation
        self.condition = condition
        self.observedDay = observedDay
        self.note = note
    }
}

public enum FeedbackOrganizer {
    public static func organize(_ text: String, knownPlaceNames: [String] = []) -> ContributionDraft {
        var draft = ContributionDraft()
        draft.placeNameHint = knownPlaceNames.filter { text.contains($0) }.max(by: { $0.count < $1.count })
        if text.contains("围栏") {
            draft.topic = .fencedArea
            draft.observation = observation(in: clause(containing: "围栏", in: text))
        } else if text.contains("室内") {
            draft.topic = .indoor
            draft.observation = observation(in: clause(containing: "室内", in: text))
        } else if text.contains("放绳") {
            draft.topic = .offLeash
            draft.observation = observation(in: clause(containing: "放绳", in: text))
        } else if text.contains("携犬") || text.contains("能进") || text.contains("不能进") {
            draft.topic = .petEntry
            draft.observation = observation(in: text)
        }
        if text.contains("每一家") || text.contains("每家店") || text.contains("店铺") {
            draft.condition = "不把场地整体当作每一家店铺的准入"
            if draft.topic == nil {
                draft.topic = .eachStore
                draft.observation = .unknown
            }
        }
        draft.observedDay = explicitDay(in: text)
        draft.note = "整理自本地文字，尚未由你确认，也不是审核结论。"
        return draft
    }

    private static func clause(containing needle: String, in text: String) -> String {
        let parts = text.components(separatedBy: CharacterSet(charactersIn: "，。,.;；"))
        return parts.first { $0.contains(needle) } ?? text
    }

    private static func observation(in text: String) -> Observation {
        if text.contains("不确定") || text.contains("不清楚") || text.contains("没看清") {
            return .observerUnsure
        }
        if text.contains("没有") || text.contains("不能") || text.contains("不允许") {
            return .observerSaysNo
        }
        if text.contains("有围栏") || text.contains("可以") || text.contains("允许") {
            return .observerSaysYes
        }
        return .unknown
    }

    /// A weekday word is not a date and is not stored.
    private static func explicitDay(in text: String) -> String? {
        let pattern = #"(20\d{2})年(\d{1,2})月(\d{1,2})日"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges == 4,
              let year = Range(match.range(at: 1), in: text),
              let month = Range(match.range(at: 2), in: text),
              let day = Range(match.range(at: 3), in: text),
              let monthNumber = Int(text[month]),
              let dayNumber = Int(text[day]) else { return nil }
        return "\(text[year])-\(String(format: "%02d", monthNumber))-\(String(format: "%02d", dayNumber))"
    }
}

public struct LocalContribution: Equatable, Codable, Sendable, Identifiable {
    public var id: String
    public var kind: String
    public var placeID: String?
    public var placeName: String
    public var city: String?
    public var category: String?
    public var latitude: Double?
    public var longitude: Double?
    public var topic: String?
    public var observation: String?
    public var condition: String?
    public var sourceNote: String?
    public var observedDay: String?
    public var syncState: String
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        kind: String,
        placeID: String? = nil,
        placeName: String,
        city: String? = nil,
        category: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        topic: String? = nil,
        observation: String? = nil,
        condition: String? = nil,
        sourceNote: String? = nil,
        observedDay: String? = nil,
        syncState: String = "仅在本机·待审核·未同步",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.placeID = placeID
        self.placeName = placeName
        self.city = city
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.topic = topic
        self.observation = observation
        self.condition = condition
        self.sourceNote = sourceNote
        self.observedDay = observedDay
        self.syncState = syncState
        self.createdAt = createdAt
    }

    public func draftPlace() -> Place? {
        guard kind == "addPlace", let latitude, let longitude else { return nil }
        let cityValue = City(rawValue: city ?? "") ?? .shanghai
        let categoryValue = PlaceCategory(rawValue: category ?? "") ?? .walking
        return Place(
            id: "draft-\(id)",
            name: placeName,
            district: "本地草稿",
            kindLabel: categoryValue.title,
            latitude: latitude,
            longitude: longitude,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-fuxing",
            exampleDistanceMeters: 0,
            blurb: "本地草稿，未同步，未经审核。\(condition ?? "")",
            rulesVerified: false,
            city: cityValue,
            category: categoryValue,
            accessRules: SampleRules.baseline(mentionsStores: categoryValue != .walking),
            isLocalDraft: true
        )
    }
}

public enum ContributionThrottle {
    public static let minimumInterval: TimeInterval = 15
    public static let maxStored = 30
    public static let notice = "刚刚已经记下一条。请稍后再试。这只是本机的间隔，不是安全防护。"

    public static func allow(now: Date, last: Date?) -> Bool {
        guard let last else { return true }
        return now.timeIntervalSince(last) >= minimumInterval
    }

    public static func appending(_ item: LocalContribution, to items: [LocalContribution]) -> [LocalContribution] {
        Array((items + [item]).suffix(maxStored))
    }
}

public enum StorageKey {
    public static let favorites = "pawtrust.favorites.v1"
    public static let profile = "pawtrust.dog-profile.v1"
    public static let contributions = "pawtrust.contributions.v1"
    public static let demoAccess = "pawtrust.demo-access.v1"
    /// Isolated defaults domain for debug screenshot launches. Wiped at each launch.
    public static let screenshotSuite = "pawtrust.screenshot.transient"
}
