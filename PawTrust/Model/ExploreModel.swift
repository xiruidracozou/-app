import MapKit
import SwiftUI
import UIKit
import PawTrustCore

enum LocationBanner: Equatable {
    case requesting
    case denied
    case failed
    case resetRegion

    var message: String {
        switch self {
        case .requesting:
            "正在请求位置，用来排序附近的示例公园。"
        case .denied:
            "定位未允许。仍可浏览示例，距离为示意。"
        case .failed:
            "没有拿到位置。仍可浏览示例，距离为示意。"
        case .resetRegion:
            "已回到上海示例区域。未定位时距离为示意。"
        }
    }

    var showsSettings: Bool { self == .denied }

    var symbolName: String {
        switch self {
        case .requesting: "location"
        case .denied, .failed: "location.slash"
        case .resetRegion: "map"
        }
    }
}

@MainActor
@Observable
final class ExploreModel {
    var state: ExploreState
    var camera: MapCameraPosition
    var banner: LocationBanner?
    var routePrompt: RouteHandoff?
    let channel: BuildChannel
    var access: MapAccess
    var profile: DogProfile?
    var draft: DogProfile
    var licenseImage: UIImage?
    var rawOCRLines: [String]
    var contributions: [LocalContribution]
    var lastContributionAt: Date?
    var composerText: String
    var mapCenter: Coordinate?
    var statusMessage: String?
    var contributionPlaceID: String?
    var showNewPlace = false
    var showProfile = false
    var captureToken = UUID()

    private let defaults: UserDefaults
    private let location: LocationProvider

    init(defaults: UserDefaults = .standard, location: LocationProvider? = nil, channel: BuildChannel) {
        let storedProfile = defaults.data(forKey: StorageKey.profile).flatMap {
            try? JSONDecoder().decode(DogProfile.self, from: $0)
        }
        let storedContributions = defaults.data(forKey: StorageKey.contributions).flatMap {
            try? JSONDecoder().decode([LocalContribution].self, from: $0)
        } ?? []
        var initial = ExploreState.initial()
        let drafts = storedContributions.compactMap { $0.draftPlace() }
        if !drafts.isEmpty {
            initial.places = SampleCatalog.places + drafts
        }
        if let data = defaults.data(forKey: StorageKey.favorites),
           let snapshot = try? JSONDecoder().decode(FavoriteSnapshot.self, from: data) {
            initial = ExploreLogic.applyingFavorites(snapshot, to: initial)
        }
        self.defaults = defaults
        self.channel = channel
        self.state = initial
        self.camera = .region(MapRegions.mk(SampleCatalog.initialRegion))
        self.mapCenter = SampleCatalog.initialRegion.center
        self.profile = storedProfile
        self.draft = storedProfile ?? .empty
        self.rawOCRLines = []
        self.contributions = storedContributions
        self.composerText = ""
        self.access = AccessController.resolvingLaunch(
            channel: channel,
            hasProfile: storedProfile?.hasAnyPetFact == true,
            storedDemoFlag: defaults.bool(forKey: StorageKey.demoAccess)
        )
        let provider = location ?? LocationProvider()
        self.location = provider
        provider.onEvent = { [weak self] event in
            self?.handle(event)
        }
    }

    var holdsSensitiveMaterial: Bool {
        licenseImage != nil || !rawOCRLines.isEmpty
    }

    var visiblePlaces: [Place] { ExploreLogic.visiblePlaces(state) }
    var summary: PeekSummary { ExploreLogic.peekSummary(state) }
    var selectedPlace: Place? { ExploreLogic.selectedPlace(state) }

    func place(_ id: String) -> Place? {
        state.places.first { $0.id == id }
    }

    func isFavorite(_ id: String) -> Bool {
        ExploreLogic.isFavorite(state, id: id)
    }

    func setQuery(_ query: String) {
        state = ExploreLogic.settingQuery(state, query)
    }

    func toggleFilter(_ filter: PlaceFilter) {
        state = ExploreLogic.togglingFilter(state, filter)
    }

    func clearAttributeFilters() {
        state = ExploreLogic.clearingFilters(state)
    }

    func toggleSelection(_ id: String) {
        state = ExploreLogic.togglingSelection(state, id: id)
    }

    func setDetent(_ detent: SheetDetent) {
        state = ExploreLogic.settingDetent(state, detent)
    }

    func stepDetent(up: Bool) {
        setDetent(state.detent.stepped(up: up))
    }

    func toggleFavorite(_ id: String) {
        state = ExploreLogic.togglingFavorite(state, id: id)
        persistFavorites()
    }

    func toggleFavoritesOnly() {
        state = ExploreLogic.settingFavoritesOnly(state, !state.favoritesOnly)
    }

    func performPeekAction() {
        switch summary.action {
        case .openSuggested:
            if let id = summary.suggestedPlaceID {
                state = ExploreLogic.togglingSelection(state, id: id)
            }
        case .showAll:
            state = ExploreLogic.showingAllPlaces(state)
        case .clearSearchAndFilters:
            state = ExploreLogic.clearingSearchAndFilters(state)
        }
    }

    func requestNearby() {
        banner = .requesting
        location.requestOnce()
    }

    func recenter() {
        if state.locationAuth == .granted, let coordinate = state.userCoordinate {
            banner = nil
            focus(on: coordinate, spanLatitude: CameraFocus.userSpanLatitude, spanLongitude: CameraFocus.userSpanLongitude)
            return
        }
        if state.locationAuth == .denied {
            focusInitial()
            banner = .resetRegion
            return
        }
        requestNearby()
    }

    func dismissBanner() {
        banner = nil
    }

    func confirmRoute(for place: Place) {
        routePrompt = RouteHandoff.make(for: place)
    }

    func openPromptedRoute() {
        guard let routePrompt else { return }
        AppleMapsRoute.openWalking(routePrompt)
        self.routePrompt = nil
    }

    func focus(on place: Place) {
        let center = CameraFocus.center(placing: place.coordinate, spanLatitude: CameraFocus.selectionSpanLatitude)
        focus(
            on: center,
            spanLatitude: CameraFocus.selectionSpanLatitude,
            spanLongitude: CameraFocus.selectionSpanLongitude
        )
    }

    func focusInitial() {
        camera = .region(MapRegions.mk(SampleCatalog.initialRegion))
    }

    func handle(_ event: LocationEvent) {
        switch event {
        case .requesting:
            banner = .requesting
        case .granted(let coordinate):
            state = ExploreLogic.applyingLocation(state, auth: .granted, coordinate: coordinate)
            banner = nil
            focus(on: coordinate, spanLatitude: CameraFocus.userSpanLatitude, spanLongitude: CameraFocus.userSpanLongitude)
        case .denied:
            state = ExploreLogic.applyingLocation(state, auth: .denied, coordinate: nil)
            banner = .denied
        case .failed:
            let keep = state.locationAuth == .granted ? state.userCoordinate : nil
            let auth: LocationAuth
            if state.locationAuth == .denied {
                auth = .denied
            } else if state.locationAuth == .granted {
                auth = .granted
            } else {
                auth = .unavailable
            }
            state = ExploreLogic.applyingLocation(state, auth: auth, coordinate: keep)
            banner = auth == .denied ? .denied : .failed
        }
    }

    private func focus(on coordinate: Coordinate, spanLatitude: Double, spanLongitude: Double) {
        camera = .region(MapRegions.mk(
            center: coordinate,
            latitudeDelta: spanLatitude,
            longitudeDelta: spanLongitude
        ))
    }

    func applyComposer(_ text: String) {
        let previousCity = state.cityFilter
        composerText = text
        state = ExploreLogic.applyingComposer(state, text: text)
        if let profile, state.asksAboutRules {
            let updated = ProfileLearning.apply(search: state.queryContext, to: profile)
            if updated != profile {
                self.profile = updated
                persistProfile()
            }
        }
        if state.cityFilter != previousCity, let city = state.cityFilter {
            camera = .region(MapRegions.mk(SampleCatalog.region(for: city)))
        }
    }

    func selectCity(_ city: City?) {
        state = ExploreLogic.settingCity(state, city)
        guard let city else { return }
        camera = .region(MapRegions.mk(SampleCatalog.region(for: city)))
    }

    func removeTopic(_ topic: RuleTopic) {
        state = ExploreLogic.removingTopic(state, topic)
    }

    func ingest(_ image: UIImage) async {
        let token = UUID()
        captureToken = token
        licenseImage = image
        let lines = await OnDeviceTextReader.recognize(image)
        guard captureToken == token else { return }
        applyRecognizedLines(lines)
        licenseImage = nil
    }

    func applyRecognizedLines(_ lines: [String]) {
        rawOCRLines = lines
        let extracted = LicenseExtractor.extract(lines: lines, now: Date()).asProfile()
        draft.dogName = extracted.dogName
        draft.breed = extracted.breed
        draft.sex = extracted.sex
        draft.ageBand = extracted.ageBand
        draft.size = extracted.size
        rawOCRLines = []
        if extracted.hasAnyPetFact {
            statusMessage = "只留下了白名单里的犬只字段。主人姓名、证件号、芯片号和原图没有进入档案。"
        } else {
            statusMessage = "没有读到品种、性别、年龄段或体型。可以自己填写。原图不会保存。"
        }
    }

    func discardSensitiveMaterial() {
        captureToken = UUID()
        licenseImage = nil
        rawOCRLines = []
    }

    func saveLocalProfile() {
        guard draft.hasAnyPetFact else {
            statusMessage = "还没有可保存的犬只字段。"
            return
        }
        profile = draft
        persistProfile()
        discardSensitiveMaterial()
        if !access.showsMap {
            access = AccessController.afterProfileSaved()
        }
        statusMessage = "档案已留在这台设备，可以清除。正式地图仍要等核验结果，保存本身不会解锁。"
    }

    func clearLocalProfile() {
        profile = nil
        draft = .empty
        defaults.removeObject(forKey: StorageKey.profile)
        defaults.removeObject(forKey: StorageKey.demoAccess)
        access = AccessController.initial()
        showProfile = false
        discardSensitiveMaterial()
        statusMessage = "本机犬只档案已清除。相册里的原图不由这个应用删除。"
    }

    func setLearning(_ enabled: Bool) {
        draft = draft.settingLearning(enabled)
        profile = profile?.settingLearning(enabled)
        if profile != nil { persistProfile() }
    }

    func requestVerification() {
        let decision = UnavailableDogLicenseVerifier().evaluate()
        let hasProfile = profile?.hasAnyPetFact == true
        if access.showsMap, channel == .debug {
            statusMessage = DemoCopy.verifierUnavailable
            return
        }
        access = AccessController.afterVerification(decision, hasProfile: hasProfile)
        statusMessage = DemoCopy.verifierUnavailable
    }

    func enterExplicitDemo() {
        let next = AccessController.afterExplicitDemo(
            channel: channel,
            hasProfile: profile?.hasAnyPetFact == true
        )
        access = next
        if case .demo = next {
            defaults.set(true, forKey: StorageKey.demoAccess)
            statusMessage = DemoCopy.demoBanner
        } else {
            defaults.set(false, forKey: StorageKey.demoAccess)
            statusMessage = "演示入口只在调试构建里、并且已经有本机档案时打开。这不是审核通过。"
        }
    }

    func leaveDemo() {
        defaults.set(false, forKey: StorageKey.demoAccess)
        access = profile?.hasAnyPetFact == true
            ? AccessController.afterProfileSaved()
            : AccessController.initial()
    }

    func noteMapCenter(_ coordinate: CLLocationCoordinate2D) {
        mapCenter = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func saveContribution(_ item: LocalContribution) -> String? {
        let now = Date()
        guard ContributionThrottle.allow(now: now, last: lastContributionAt) else {
            return ContributionThrottle.notice
        }
        lastContributionAt = now
        contributions = ContributionThrottle.appending(item, to: contributions)
        persistContributions()
        if let draftPlace = item.draftPlace() {
            state.places.append(draftPlace)
        }
        return nil
    }

    func deleteContribution(_ id: String) {
        contributions.removeAll { $0.id == id }
        state.places.removeAll { $0.id == "draft-\(id)" }
        persistContributions()
    }

    private func persistProfile() {
        guard let profile, let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: StorageKey.profile)
    }

    private func persistContributions() {
        if let data = try? JSONEncoder().encode(contributions) {
            defaults.set(data, forKey: StorageKey.contributions)
        }
    }

    private func persistFavorites() {
        let snapshot = FavoriteSnapshot(state: state)
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: StorageKey.favorites)
        }
    }
}

enum MapRegions {
    static func mk(_ region: MapRegion) -> MKCoordinateRegion {
        mk(center: region.center, latitudeDelta: region.latitudeDelta, longitudeDelta: region.longitudeDelta)
    }

    static func mk(center: Coordinate, latitudeDelta: Double, longitudeDelta: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }
}
