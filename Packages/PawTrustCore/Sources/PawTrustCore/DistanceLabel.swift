import Foundation

public struct DistancePresentation: Equatable, Sendable {
    public let meters: Int
    public let isExample: Bool
    public let primary: String
    public let detailNote: String
    public let accessibilityLabel: String

    public init(
        meters: Int,
        isExample: Bool,
        primary: String,
        detailNote: String,
        accessibilityLabel: String
    ) {
        self.meters = meters
        self.isExample = isExample
        self.primary = primary
        self.detailNote = detailNote
        self.accessibilityLabel = accessibilityLabel
    }
}

public enum DistanceLabel {
    public static let exampleNote = "未使用你的位置，这段距离来自示例数据。"
    public static let liveNote = "按你的当前位置估算，只说明远近，不是路线长度。"
    public static let herePrimary = "约在这个位置"

    public static func make(meters rawMeters: Double, isExample: Bool) -> DistancePresentation {
        let safe = max(0, rawMeters)
        if !isExample && safe < 30 {
            return DistancePresentation(
                meters: Int(safe.rounded()),
                isExample: false,
                primary: herePrimary,
                detailNote: liveNote,
                accessibilityLabel: "按当前位置，大约就在这个公园。\(liveNote)"
            )
        }

        let rounded = Int((safe / 10).rounded(.toNearestOrAwayFromZero) * 10)
        let prefix = isExample ? "示意约 " : "约 "
        let primary: String
        let shown: Int
        if rounded >= 1_000 {
            let tenths = Int((Double(rounded) / 100).rounded(.toNearestOrAwayFromZero))
            let whole = tenths / 10
            let frac = abs(tenths % 10)
            primary = "\(prefix)\(whole).\(frac) 公里"
            shown = tenths * 100
        } else {
            let meters = max(10, rounded)
            primary = "\(prefix)\(meters) 米"
            shown = meters
        }

        let detail = isExample ? exampleNote : liveNote
        let access = isExample
            ? "示意距离\(primary)。\(exampleNote)"
            : "距离\(primary)。\(liveNote)"
        return DistancePresentation(
            meters: shown,
            isExample: isExample,
            primary: primary,
            detailNote: detail,
            accessibilityLabel: access
        )
    }
}
