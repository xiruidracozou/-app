import Foundation

public enum SheetMotion {
    /// `velocity` is points per second. Positive velocity moves downward and prefers a shorter sheet.
    public static func resolve(
        projectedHeight: Double,
        velocity: Double,
        peek: Double,
        medium: Double,
        large: Double
    ) -> SheetDetent {
        let adjusted = min(max(projectedHeight - velocity * 0.12, peek), large)
        let stops: [(SheetDetent, Double)] = [
            (.peek, peek),
            (.medium, medium),
            (.large, large),
        ]
        return stops.min { abs($0.1 - adjusted) < abs($1.1 - adjusted) }!.0
    }
}
