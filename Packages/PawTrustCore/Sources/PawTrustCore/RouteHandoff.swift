import Foundation

public struct RouteHandoff: Equatable, Sendable {
    public let placeID: String
    public let placeName: String
    public let coordinate: Coordinate
    /// The system Maps app plans the walk. This value stays true.
    public let leavesApp: Bool
    /// There is no in-app line, turn list, or navigation session.
    public let providesInAppRoute: Bool
    public let boundaryStatement: String

    public init(
        placeID: String,
        placeName: String,
        coordinate: Coordinate,
        leavesApp: Bool,
        providesInAppRoute: Bool,
        boundaryStatement: String
    ) {
        self.placeID = placeID
        self.placeName = placeName
        self.coordinate = coordinate
        self.leavesApp = leavesApp
        self.providesInAppRoute = providesInAppRoute
        self.boundaryStatement = boundaryStatement
    }

    public static func make(for place: Place) -> RouteHandoff {
        RouteHandoff(
            placeID: place.id,
            placeName: place.name,
            coordinate: place.coordinate,
            leavesApp: true,
            providesInAppRoute: false,
            boundaryStatement: DemoCopy.routeBoundary
        )
    }
}
