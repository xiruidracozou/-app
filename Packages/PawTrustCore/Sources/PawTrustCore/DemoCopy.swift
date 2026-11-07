import Foundation

/// User-facing boundaries. Views read these constants so the words under test
/// are the words on screen.
public enum DemoCopy {
    public static let unverifiedBadge = "示例地点 · 规则未核实"
    public static let mapCaption = "真实公园位置 · 携犬规则未核实"
    public static let routeButtonTitle = "查看步行路线"
    public static let routeFootnote = "在 Apple 地图中打开。本应用不提供导航。"
    public static let routeBoundary = "将离开爪印识途，由 Apple 地图规划步行路线。本应用不绘制路线，也不核实公园是否允许携犬或是否必须牵绳。"
    public static let photoBadge = "示例照片"
    public static let photoExplanation = "示例照片，不是该公园实拍，也不是实时画面。"
    public static let attributeNote = "以下属性为未核实示例"
    public static let readingGuide = "公园名称和坐标是公开地点，用来在 Apple 地图上显示位置。牵绳、围栏、水源、照片和未定位时的距离都是演示数据，未核实，不是许可、风险评级或法律结论。"
    public static let brandName = "PawTrust"
    public static let brandMark = "爪印识途"
}
