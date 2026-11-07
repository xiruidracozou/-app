import MapKit
import SwiftUI
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
    private static let favoritesKey = "pawtrust.favorites.v1"

    var state: ExploreState
    var camera: MapCameraPosition
    var banner: LocationBanner?
    var routePrompt: RouteHandoff?

    private let defaults: UserDefaults
    private let location: LocationProvider

    init(defaults: UserDefaults = .standard, location: LocationProvider? = nil) {
        var initial = ExploreState.initial()
        if let data = defaults.data(forKey: Self.favoritesKey),
           let snapshot = try? JSONDecoder().decode(FavoriteSnapshot.self, from: data) {
            initial = ExploreLogic.applyingFavorites(snapshot, to: initial)
        }
        self.defaults = defaults
        self.state = initial
        self.camera = .region(MapRegions.mk(SampleCatalog.initialRegion))
        let provider = location ?? LocationProvider()
        self.location = provider
        provider.onEvent = { [weak self] event in
            self?.handle(event)
        }
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

    private func persistFavorites() {
        let snapshot = FavoriteSnapshot(state: state)
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: Self.favoritesKey)
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
