import Foundation

public enum ExploreLogic {
    public static func visiblePlaces(_ state: ExploreState) -> [Place] {
        let query = normalized(state.query)
        var result = state.places.filter { place in
            if let city = state.cityFilter, place.city != city { return false }
            if let category = state.categoryFilter, place.category != category { return false }
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
        if state.asksAboutRules {
            let split = RuleMatcher.split(places: result, topics: state.requiredTopics)
            let order = (split.matched + split.unknown).map(\.placeID)
            result = order.compactMap { id in result.first { $0.id == id } }
        }
        if state.locationAuth == .granted, let user = state.userCoordinate {
            result.sort {
                Geo.meters(from: user, to: $0.coordinate) < Geo.meters(from: user, to: $1.coordinate)
            }
        }
        return result
    }

    public static func unknownPlaceIDs(_ state: ExploreState) -> Set<String> {
        guard state.asksAboutRules else { return [] }
        let visibleIDs = Set(visiblePlaces(state).map(\.id))
        let unknown = RuleMatcher.split(places: state.places, topics: state.requiredTopics).unknown.map(\.placeID)
        return Set(unknown.filter { visibleIDs.contains($0) })
    }

    public static func assessment(for place: Place, state: ExploreState) -> PlaceAssessment? {
        guard state.asksAboutRules else { return nil }
        return RuleMatcher.assess(place: place, topics: state.requiredTopics)
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
        if state.asksAboutRules {
            let pool = state.places.filter { place in
                if let city = state.cityFilter, place.city != city { return false }
                if let category = state.categoryFilter, place.category != category { return false }
                return true
            }
            let split = RuleMatcher.split(places: pool, topics: state.requiredTopics)
            let title = split.matched.isEmpty ? "没有已确认符合的地点" : "已确认符合"
            let subtitle = "\(split.matched.count) 个条件已确认 · \(split.unknown.count) 个条件未知"
            return PeekSummary(
                title: title,
                subtitle: subtitle,
                suggestedPlaceID: visible.first?.id,
                action: visible.isEmpty ? .clearSearchAndFilters : .openSuggested,
                accessibilityHint: "未知条件不能当作满足。\(subtitle)"
            )
        }
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
        next.cityFilter = .shanghai
        next.categoryFilter = nil
        next.requiredTopics = []
        next.nearMe = false
        next.unmatchedTerms = []
        return reconcile(next)
    }

    public static func settingCity(_ state: ExploreState, _ city: City?) -> ExploreState {
        var next = state
        next.cityFilter = city
        return reconcile(next)
    }

    public static func applyingComposer(_ state: ExploreState, text: String) -> ExploreState {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            var next = state
            next.query = ""
            next.categoryFilter = nil
            next.requiredTopics = []
            next.nearMe = false
            next.unmatchedTerms = []
            return reconcile(next)
        }
        let interpretation = LocalUtteranceInterpreter().interpret(
            trimmed,
            following: state.queryContext,
            places: state.places
        )
        if interpretation.isNameOnly {
            var next = state
            next.categoryFilter = nil
            next.requiredTopics = []
            next.nearMe = false
            next.unmatchedTerms = []
            if let city = interpretation.context.city {
                next.cityFilter = city
            }
            next.query = trimmed
            return reconcile(next)
        }
        var next = state
        next.query = ""
        next.cityFilter = interpretation.context.city
        next.categoryFilter = interpretation.context.category
        next.requiredTopics = interpretation.context.topics
        next.nearMe = interpretation.context.nearMe
        next.unmatchedTerms = interpretation.unmatched
        next.interpreterLabel = interpretation.label
        return reconcile(next)
    }

    public static func removingTopic(_ state: ExploreState, _ topic: RuleTopic) -> ExploreState {
        var next = state
        next.requiredTopics.removeAll { $0 == topic }
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
