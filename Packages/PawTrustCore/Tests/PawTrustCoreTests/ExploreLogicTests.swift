import XCTest
@testable import PawTrustCore

final class ExploreLogicTests: XCTestCase {
    func testInitialStateHasNoLocationAndShowsEverySamplePark() {
        let state = ExploreState.initial()
        XCTAssertEqual(state.locationAuth, .notRequested)
        XCTAssertNil(state.userCoordinate)
        XCTAssertNil(state.selectedPlaceID)
        XCTAssertEqual(state.detent, .peek)
        XCTAssertTrue(state.filters.isEmpty)
        XCTAssertEqual(
            ExploreLogic.visiblePlaces(state).map(\.id),
            SampleCatalog.places(in: .shanghai).map(\.id)
        )
        XCTAssertEqual(ExploreLogic.peekSummary(state).title, "附近好去处")
        XCTAssertEqual(
            ExploreLogic.peekSummary(state).subtitle,
            "\(SampleCatalog.places(in: .shanghai).count) 个示例地点"
        )
        XCTAssertEqual(ExploreLogic.peekSummary(state).suggestedPlaceID, "fuxing")
    }

    func testFiltersCombineAndSearchTrims() {
        var state = ExploreState.initial()
        state = ExploreLogic.togglingFilter(state, .offLeash)
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).map(\.id), ["xiangyang"])

        state = ExploreLogic.togglingFilter(state, .water)
        XCTAssertTrue(ExploreLogic.visiblePlaces(state).isEmpty)
        XCTAssertEqual(ExploreLogic.peekSummary(state).action, .clearSearchAndFilters)

        state = ExploreLogic.clearingFilters(state)
        state = ExploreLogic.settingQuery(state, "  徐汇  ")
        let xuhui = Set(ExploreLogic.visiblePlaces(state).map(\.id))
        XCTAssertTrue(xuhui.isSuperset(of: ["xiangyang", "binjiang"]))
        XCTAssertFalse(xuhui.contains("fuxing"))

        state = ExploreLogic.settingQuery(state, "公园")
        XCTAssertFalse(ExploreLogic.visiblePlaces(state).contains { $0.id == "binjiang" })
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).count, 4)

        state = ExploreLogic.settingQuery(state, "未核实")
        XCTAssertTrue(ExploreLogic.visiblePlaces(state).isEmpty)

        state = ExploreLogic.clearingSearchAndFilters(state)
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).count, SampleCatalog.places(in: .shanghai).count)
    }

    func testWaterAndFenceFilters() {
        let water = ExploreLogic.visiblePlaces(ExploreLogic.togglingFilter(ExploreState.initial(), .water))
        XCTAssertEqual(Set(water.map(\.id)), ["jingan", "renmin", "binjiang"])
        let fenced = ExploreLogic.visiblePlaces(ExploreLogic.togglingFilter(ExploreState.initial(), .fenced))
        XCTAssertEqual(Set(fenced.map(\.id)), ["xiangyang", "jingan"])
    }

    func testSyntheticAndFilter() {
        let extra = Place(
            id: "both",
            name: "测试绿地",
            district: "静安",
            kindLabel: "社区公园",
            latitude: 31.22,
            longitude: 121.46,
            leash: .offLeash,
            fenced: false,
            water: true,
            photoName: "place-fuxing",
            exampleDistanceMeters: 300,
            blurb: "示例描述，规则未核实。"
        )
        var state = ExploreState.initial(places: SampleCatalog.places + [extra])
        state = ExploreLogic.togglingFilter(state, .offLeash)
        state = ExploreLogic.togglingFilter(state, .water)
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).map(\.id), ["both"])
    }

    func testSelectionTogglesAndHiddenPlaceCannotBeSelected() {
        var state = ExploreState.initial()
        state = ExploreLogic.togglingSelection(state, id: "binjiang")
        XCTAssertEqual(state.selectedPlaceID, "binjiang")
        XCTAssertEqual(state.detent, .medium)

        state.detent = .large
        state = ExploreLogic.togglingSelection(state, id: "renmin")
        XCTAssertEqual(state.selectedPlaceID, "renmin")
        XCTAssertEqual(state.detent, .large)

        state = ExploreLogic.togglingSelection(state, id: "renmin")
        XCTAssertNil(state.selectedPlaceID)
        XCTAssertEqual(state.detent, .peek)

        var filtered = ExploreLogic.settingQuery(ExploreState.initial(), "滨江")
        let unchanged = ExploreLogic.togglingSelection(filtered, id: "fuxing")
        XCTAssertEqual(unchanged, filtered)
        filtered = ExploreLogic.togglingSelection(filtered, id: "binjiang")
        filtered = ExploreLogic.settingQuery(filtered, "复兴")
        XCTAssertNil(filtered.selectedPlaceID)
        XCTAssertEqual(filtered.detent, .peek)
    }

    func testDetentSelectsSuggestionAndEmptyCatalogStaysPeek() {
        let opened = ExploreLogic.settingDetent(ExploreState.initial(), .large)
        XCTAssertEqual(opened.selectedPlaceID, "fuxing")
        XCTAssertEqual(opened.detent, .large)

        let collapsed = ExploreLogic.settingDetent(opened, .peek)
        XCTAssertNil(collapsed.selectedPlaceID)
        XCTAssertEqual(collapsed.detent, .peek)

        let empty = ExploreState.initial(places: [])
        XCTAssertEqual(ExploreLogic.settingDetent(empty, .medium), empty)
        XCTAssertEqual(ExploreLogic.peekSummary(empty).action, .clearSearchAndFilters)
    }

    func testFavoritesFilterAndSnapshot() {
        var state = ExploreState.initial()
        state = ExploreLogic.togglingFavorite(state, id: "renmin")
        state = ExploreLogic.togglingSelection(state, id: "renmin")
        state = ExploreLogic.settingFavoritesOnly(state, true)
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).map(\.id), ["renmin"])
        XCTAssertEqual(state.selectedPlaceID, "renmin")

        state = ExploreLogic.togglingFavorite(state, id: "renmin")
        XCTAssertTrue(state.favoriteIDs.isEmpty)
        XCTAssertNil(state.selectedPlaceID)
        XCTAssertEqual(state.detent, .peek)
        XCTAssertEqual(ExploreLogic.peekSummary(state).action, .showAll)

        state = ExploreLogic.showingAllPlaces(state)
        XCTAssertFalse(state.favoritesOnly)
        XCTAssertEqual(ExploreLogic.visiblePlaces(state).count, SampleCatalog.places(in: .shanghai).count)

        var saved = ExploreState.initial()
        saved = ExploreLogic.togglingFavorite(saved, id: "binjiang")
        saved = ExploreLogic.togglingFavorite(saved, id: "missing")
        let snapshot = FavoriteSnapshot(state: saved)
        let encoded = try! JSONEncoder().encode(snapshot)
        let decoded = try! JSONDecoder().decode(FavoriteSnapshot.self, from: encoded)
        let restored = ExploreLogic.applyingFavorites(decoded, to: ExploreState.initial())
        XCTAssertEqual(restored.favoriteIDs, ["binjiang"])
        XCTAssertFalse(restored.favoritesOnly)

        let foreign = ExploreLogic.applyingFavorites(
            FavoriteSnapshot(version: 2, favoriteIDs: ["fuxing"]),
            to: ExploreState.initial()
        )
        XCTAssertTrue(foreign.favoriteIDs.isEmpty)
    }

    func testExampleDistanceUntilAGrantedFix() {
        let place = SampleCatalog.places.first { $0.id == "binjiang" }!
        let initial = ExploreState.initial()
        let example = ExploreLogic.distance(for: place, state: initial)
        XCTAssertTrue(example.isExample)
        XCTAssertEqual(example.primary, "示意约 800 米")
        XCTAssertEqual(example.detailNote, DistanceLabel.exampleNote)
        XCTAssertTrue(example.accessibilityLabel.contains("示意"))

        let waiting = ExploreLogic.applyingLocation(initial, auth: .granted, coordinate: nil)
        XCTAssertTrue(ExploreLogic.distance(for: place, state: waiting).isExample)

        let denied = ExploreLogic.applyingLocation(
            initial,
            auth: .denied,
            coordinate: place.coordinate
        )
        XCTAssertNil(denied.userCoordinate)
        XCTAssertTrue(ExploreLogic.distance(for: place, state: denied).isExample)

        let jingan = SampleCatalog.places.first { $0.id == "jingan" }!
        XCTAssertEqual(
            ExploreLogic.distance(for: jingan, state: initial).primary,
            "示意约 1.1 公里"
        )
    }

    func testLiveDistanceSortsAndDropsTheExampleLabel() {
        let binjiang = SampleCatalog.places.first { $0.id == "binjiang" }!
        let near = Coordinate(latitude: binjiang.latitude, longitude: binjiang.longitude + 0.009)
        let state = ExploreLogic.applyingLocation(ExploreState.initial(), auth: .granted, coordinate: near)
        let ordered = ExploreLogic.visiblePlaces(state)
        XCTAssertEqual(ordered.first?.id, "binjiang")
        let distance = ExploreLogic.distance(for: binjiang, state: state)
        XCTAssertFalse(distance.isExample)
        XCTAssertFalse(distance.primary.contains("示意"))
        XCTAssertNotEqual(distance.primary, "示意约 800 米")
        XCTAssertGreaterThan(distance.meters, 700)
        XCTAssertLessThan(distance.meters, 1_050)
        XCTAssertEqual(distance.detailNote, DistanceLabel.liveNote)

        let onTop = ExploreLogic.applyingLocation(
            ExploreState.initial(),
            auth: .granted,
            coordinate: binjiang.coordinate
        )
        let here = ExploreLogic.distance(for: binjiang, state: onTop)
        XCTAssertEqual(here.primary, DistanceLabel.herePrimary)
        XCTAssertFalse(here.isExample)
        XCTAssertFalse(here.detailNote.contains("示例数据"))
    }

    func testSheetStepsAndRouteHandoffHasNoInAppLine() {
        XCTAssertEqual(SheetDetent.peek.stepped(up: true), .medium)
        XCTAssertEqual(SheetDetent.large.stepped(up: true), .large)
        XCTAssertEqual(SheetDetent.medium.stepped(up: false), .peek)

        let place = SampleCatalog.places[4]
        let handoff = RouteHandoff.make(for: place)
        XCTAssertTrue(handoff.leavesApp)
        XCTAssertFalse(handoff.providesInAppRoute)
        XCTAssertEqual(handoff.coordinate, place.coordinate)
        XCTAssertEqual(handoff.boundaryStatement, DemoCopy.routeBoundary)
        XCTAssertTrue(handoff.boundaryStatement.contains("Apple 地图"))
        XCTAssertTrue(handoff.boundaryStatement.contains("不绘制路线"))
        XCTAssertTrue(handoff.boundaryStatement.contains("不核实"))
    }
}
