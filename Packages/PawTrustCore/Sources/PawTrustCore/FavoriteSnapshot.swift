import Foundation

public struct FavoriteSnapshot: Codable, Equatable, Sendable {
    public var version: Int
    public var favoriteIDs: [String]

    public init(version: Int = 1, favoriteIDs: [String]) {
        self.version = version
        self.favoriteIDs = favoriteIDs
    }

    public init(state: ExploreState) {
        self.version = 1
        self.favoriteIDs = state.favoriteIDs.sorted()
    }
}
