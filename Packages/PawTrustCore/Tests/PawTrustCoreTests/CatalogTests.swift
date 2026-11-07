import XCTest
@testable import PawTrustCore

final class CatalogTests: XCTestCase {
    func testSampleParksStayInsideTheOpeningMap() {
        XCTAssertEqual(Set(SampleCatalog.places.map(\.id)).count, SampleCatalog.places.count)
        XCTAssertGreaterThan(SampleCatalog.places(in: .shanghai).count, 0)
        XCTAssertGreaterThan(SampleCatalog.places(in: .shenzhen).count, 0)
        XCTAssertTrue(SampleCatalog.places.contains { $0.category == .walking })
        XCTAssertTrue(SampleCatalog.places.contains { $0.category == .dining })
        XCTAssertTrue(SampleCatalog.places.contains { $0.category == .mall })
        for place in SampleCatalog.places {
            let region = SampleCatalog.region(for: place.city)
            XCTAssertTrue(region.contains(place.coordinate, insetFraction: 0.05), place.name)
            XCTAssertFalse(place.rulesVerified)
            XCTAssertTrue(place.blurb.contains("未核实"))
            XCTAssertFalse(place.accessRules.contains { $0.value.countsAsSatisfied || $0.value == .statedAllowed })
            XCTAssertFalse(place.photoName.isEmpty)
            XCTAssertGreaterThan(place.exampleDistanceMeters, 0)
        }
        XCTAssertTrue(SampleCatalog.places.contains { $0.accessRules.contains { $0.topic == .eachStore } })
    }

    func testCopyDoesNotClaimALegalConclusion() {
        let banned = ["合法", "已核实", "官方许可", "保证安全", "法律允许", "已批准"]
        let blobs = SampleCatalog.places.map { $0.blurb + $0.kindLabel + $0.name }
            + [
                DemoCopy.unverifiedBadge,
                DemoCopy.mapCaption,
                DemoCopy.routeBoundary,
                DemoCopy.routeFootnote,
                DemoCopy.photoExplanation,
                DemoCopy.attributeNote,
                DemoCopy.readingGuide,
                DemoCopy.demoBanner,
                DemoCopy.verifierUnavailable,
                DemoCopy.localParseLabel,
                DemoCopy.retentionSummary,
                DistanceLabel.exampleNote,
                DistanceLabel.liveNote,
            ]
        for blob in blobs {
            for word in banned {
                XCTAssertFalse(blob.contains(word), "\(word) in \(blob)")
            }
        }
        XCTAssertEqual(DemoCopy.unverifiedBadge, "示例地点 · 规则未核实")
        XCTAssertEqual(DemoCopy.mapCaption, "真实地点位置 · 携犬规则未核实")
        XCTAssertEqual(DemoCopy.localParseLabel.contains("本地解析"), true)
        XCTAssertFalse(DemoCopy.localParseLabel.contains("LLM"))
    }

    func testDistanceRoundingAndFocusShift() {
        XCTAssertEqual(DistanceLabel.make(meters: 800, isExample: false).primary, "约 800 米")
        XCTAssertEqual(DistanceLabel.make(meters: 1_500, isExample: false).primary, "约 1.5 公里")
        XCTAssertEqual(DistanceLabel.make(meters: 999, isExample: false).primary, "约 1.0 公里")
        XCTAssertEqual(DistanceLabel.make(meters: 20, isExample: false).primary, DistanceLabel.herePrimary)
        XCTAssertEqual(DistanceLabel.make(meters: 20, isExample: true).primary, "示意约 20 米")
        XCTAssertTrue(DistanceLabel.make(meters: 20, isExample: true).isExample)

        let equator = Geo.meters(
            from: Coordinate(latitude: 0, longitude: 0),
            to: Coordinate(latitude: 1, longitude: 0)
        )
        XCTAssertEqual(equator, 6_371_000 * .pi / 180, accuracy: 1)
        XCTAssertEqual(
            Geo.meters(
                from: Coordinate(latitude: 31.2, longitude: 121.4),
                to: Coordinate(latitude: 31.2, longitude: 121.4)
            ),
            0,
            accuracy: 0.001
        )

        let park = Coordinate(latitude: 31.1882, longitude: 121.4602)
        let focus = CameraFocus.center(placing: park, spanLatitude: CameraFocus.selectionSpanLatitude)
        XCTAssertLessThan(focus.latitude, park.latitude)
        XCTAssertEqual(focus.longitude, park.longitude)
    }

    func testSheetMotionUsesReleasePositionAndFlick() {
        let peek = 160.0
        let medium = 420.0
        let large = 680.0
        XCTAssertEqual(SheetMotion.resolve(projectedHeight: 160, velocity: 0, peek: peek, medium: medium, large: large), .peek)
        XCTAssertEqual(SheetMotion.resolve(projectedHeight: 400, velocity: 0, peek: peek, medium: medium, large: large), .medium)
        XCTAssertEqual(SheetMotion.resolve(projectedHeight: 200, velocity: -2_000, peek: peek, medium: medium, large: large), .medium)
        XCTAssertEqual(SheetMotion.resolve(projectedHeight: 420, velocity: 2_000, peek: peek, medium: medium, large: large), .peek)
        XCTAssertEqual(SheetMotion.resolve(projectedHeight: 500, velocity: -2_500, peek: peek, medium: medium, large: large), .large)
    }
}
