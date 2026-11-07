import Foundation

public enum ExploreLogic {
    public static func visiblePlaces(_ state: ExploreState) -> [Place] {
        let query = normalized(state.query)
        var result = state.places.filter { place in
            if state.favoritesOnly && !state.favoriteIDs.contains(place.id) {
                return false
            }
            if !state.filters.allSatisfy(place.matches) {
                return false
            }
            if query.isEmpty { return true }
            let haystack = normalized("\(place.name) \(place.district) \(place.kindLabel)")
            return haystack.contains(query)
        }
        if state.locationAuth == .granted, let user = state.userCoordinate {
            result.sort {
                Geo.meters(from: user, to: $0.coordinate) < Geo.meters(from: user, to: $1.coordinate)
            }
        }
        return result
    }

    public static func suggestedPlace(_ state: ExploreState) -> Place? {
        visiblePlaces(state).first
    }

    public static func distance(for place: Place, state: ExploreState) -> DistancePresentation {
        if let user = state.userCoordinate, state.locationAuth == .granted {
            return DistanceLabel.make(
                meters: Geo.meters(from: user, to: place.coordinate),
                isExample: false
            )
        }
        return DistanceLabel.make(meters: Double(place.exampleDistanceMeters), isExample: true)
    }

    public static func peekSummary(_ state: ExploreState) -> PeekSummary {
        let visible = visiblePlaces(state)
        if let first = visible.first {
            let distance = distance(for: first, state: state)
            let title = state.favoritesOnly ? "已收藏的去处" : "附近好去处"
            return PeekSummary(
                title: title,
                subtitle: "\(visible.count) 个示例地点",
                suggestedPlaceID: first.id,
                action: .openSuggested,
                accessibilityHint: "查看\(first.name)。\(distance.accessibilityLabel)"
            )
        }
        if state.favoritesOnly
            && state.favoriteIDs.isEmpty
            && normalized(state.query).isEmpty
            && state.filters.isEmpty
        {
            return PeekSummary(
                title: "还没有收藏",
                subtitle: "点书签可以把示例地点留在这台设备上",
                suggestedPlaceID: nil,
                action: .showAll,
                accessibilityHint: "关闭仅看收藏"
            )
        }
        return PeekSummary(
            title: "没有符合的示例",
            subtitle: "搜索和筛选没有命中",
            suggestedPlaceID: nil,
            action: .clearSearchAndFilters,
            accessibilityHint: "清除搜索和筛选"
        )
    }

    public static func togglingSelection(_ state: ExploreState, id: String) -> ExploreState {
        var next = state
        if next.selectedPlaceID == id {
            next.selectedPlaceID = nil
            next.detent = .peek
            return next
        }
        guard visiblePlaces(next).contains(where: { $0.id == id }) else { return state }
        next.selectedPlaceID = id
        if next.detent == .peek {
            next.detent = .medium
        }
        return next
    }

    public static func settingDetent(_ state: ExploreState, _ detent: SheetDetent) -> ExploreState {
        var next = state
        if detent == .peek {
            next.selectedPlaceID = nil
            next.detent = .peek
            return next
        }
        if next.selectedPlaceID == nil {
            guard let suggested = suggestedPlace(next) else { return state }
            next.selectedPlaceID = suggested.id
        }
        next.detent = detent
        return next
    }

    public static func togglingFavorite(_ state: ExploreState, id: String) -> ExploreState {
        var next = state
        if next.favoriteIDs.contains(id) {
            next.favoriteIDs.remove(id)
        } else {
            next.favoriteIDs.insert(id)
        }
        return reconcile(next)
    }

    public static func settingFavoritesOnly(_ state: ExploreState, _ on: Bool) -> ExploreState {
        var next = state
        next.favoritesOnly = on
        return reconcile(next)
    }

    public static func togglingFilter(_ state: ExploreState, _ filter: PlaceFilter) -> ExploreState {
        var next = state
        if next.filters.contains(filter) {
            next.filters.remove(filter)
        } else {
            next.filters.insert(filter)
        }
        return reconcile(next)
    }

    public static func clearingFilters(_ state: ExploreState) -> ExploreState {
        var next = state
        next.filters.removeAll()
        return reconcile(next)
    }

    public static func settingQuery(_ state: ExploreState, _ query: String) -> ExploreState {
        var next = state
        next.query = query
        return reconcile(next)
    }

    public static func clearingSearchAndFilters(_ state: ExploreState) -> ExploreState {
        var next = state
        next.query = ""
        next.filters.removeAll()
        next.favoritesOnly = false
        return reconcile(next)
    }

    public static func showingAllPlaces(_ state: ExploreState) -> ExploreState {
        var next = state
        next.favoritesOnly = false
        return reconcile(next)
    }

    public static func applyingLocation(
        _ state: ExploreState,
        auth: LocationAuth,
        coordinate: Coordinate?
    ) -> ExploreState {
        var next = state
        next.locationAuth = auth
        next.userCoordinate = auth == .granted ? coordinate : nil
        return next
    }

    public static func applyingFavorites(_ snapshot: FavoriteSnapshot, to state: ExploreState) -> ExploreState {
        guard snapshot.version == 1 else { return state }
        var next = state
        let known = Set(state.places.map(\.id))
        next.favoriteIDs = Set(snapshot.favoriteIDs.filter { known.contains($0) })
        return reconcile(next)
    }

    public static func selectedPlace(_ state: ExploreState) -> Place? {
        guard let id = state.selectedPlaceID else { return nil }
        return visiblePlaces(state).first { $0.id == id } ?? state.places.first { $0.id == id }
    }

    public static func isFavorite(_ state: ExploreState, id: String) -> Bool {
        state.favoriteIDs.contains(id)
    }

    private static func reconcile(_ state: ExploreState) -> ExploreState {
        var next = state
        let visibleIDs = Set(visiblePlaces(next).map(\.id))
        if let selected = next.selectedPlaceID, !visibleIDs.contains(selected) {
            next.selectedPlaceID = nil
            next.detent = .peek
        }
        return next
    }

    private static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
