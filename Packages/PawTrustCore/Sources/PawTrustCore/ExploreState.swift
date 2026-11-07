import Foundation

public enum LocationAuth: String, Codable, Equatable, Sendable {
    case notRequested
    case granted
    case denied
    case unavailable
}

public enum SheetDetent: Int, CaseIterable, Equatable, Comparable, Sendable {
    case peek = 0
    case medium = 1
    case large = 2

    public static func < (lhs: SheetDetent, rhs: SheetDetent) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var title: String {
        switch self {
        case .peek: "收起"
        case .medium: "半屏"
        case .large: "展开"
        }
    }

    public func stepped(up: Bool) -> SheetDetent {
        let next = rawValue + (up ? 1 : -1)
        return SheetDetent(rawValue: min(max(next, 0), SheetDetent.large.rawValue)) ?? self
    }
}

public struct ExploreState: Equatable, Sendable {
    public var places: [Place]
    public var query: String
    public var filters: Set<PlaceFilter>
    public var favoriteIDs: Set<String>
    public var favoritesOnly: Bool
    public var selectedPlaceID: String?
    public var detent: SheetDetent
    public var userCoordinate: Coordinate?
    public var locationAuth: LocationAuth
    public var cityFilter: City?
    public var categoryFilter: PlaceCategory?
    public var requiredTopics: [RuleTopic]
    public var nearMe: Bool
    public var unmatchedTerms: [String]
    public var interpreterLabel: String

    public init(
        places: [Place],
        query: String = "",
        filters: Set<PlaceFilter> = [],
        favoriteIDs: Set<String> = [],
        favoritesOnly: Bool = false,
        selectedPlaceID: String? = nil,
        detent: SheetDetent = .peek,
        userCoordinate: Coordinate? = nil,
        locationAuth: LocationAuth = .notRequested,
        cityFilter: City? = .shanghai,
        categoryFilter: PlaceCategory? = nil,
        requiredTopics: [RuleTopic] = [],
        nearMe: Bool = false,
        unmatchedTerms: [String] = [],
        interpreterLabel: String = LocalUtteranceInterpreter.label
    ) {
        self.places = places
        self.query = query
        self.filters = filters
        self.favoriteIDs = favoriteIDs
        self.favoritesOnly = favoritesOnly
        self.selectedPlaceID = selectedPlaceID
        self.detent = detent
        self.userCoordinate = userCoordinate
        self.locationAuth = locationAuth
        self.cityFilter = cityFilter
        self.categoryFilter = categoryFilter
        self.requiredTopics = requiredTopics
        self.nearMe = nearMe
        self.unmatchedTerms = unmatchedTerms
        self.interpreterLabel = interpreterLabel
    }

    public var asksAboutRules: Bool { !requiredTopics.isEmpty }

    public var queryContext: QueryContext {
        QueryContext(city: cityFilter, category: categoryFilter, topics: requiredTopics, nearMe: nearMe)
    }

    public static func initial(places: [Place] = SampleCatalog.places) -> ExploreState {
        ExploreState(places: places)
    }
}

public struct PeekSummary: Equatable, Sendable {
    public enum Action: Equatable, Sendable {
        case openSuggested
        case showAll
        case clearSearchAndFilters
    }

    public let title: String
    public let subtitle: String
    public let suggestedPlaceID: String?
    public let action: Action
    public let accessibilityHint: String

    public init(
        title: String,
        subtitle: String,
        suggestedPlaceID: String?,
        action: Action,
        accessibilityHint: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.suggestedPlaceID = suggestedPlaceID
        self.action = action
        self.accessibilityHint = accessibilityHint
    }
}
