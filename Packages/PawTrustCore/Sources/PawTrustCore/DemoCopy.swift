import Foundation

/// User-facing boundaries. Views read these constants so the words under test
/// are the words on screen.
public enum DemoCopy {
    public static let unverifiedBadge = "示例地点 · 规则未核实"
    public static let mapCaption = "真实地点位置 · 携犬规则未核实"
    public static let routeButtonTitle = "查看步行路线"
    public static let routeFootnote = "在 Apple 地图中打开。本应用不提供导航。"
    public static let routeBoundary = "将离开爪印识途，由 Apple 地图规划步行路线。本应用不绘制路线，也不核实公园是否允许携犬或是否必须牵绳。"
    public static let photoBadge = "示例照片"
    public static let photoExplanation = "示例照片，不是该地点实拍，也不是实时画面。"
    public static let attributeNote = "以下属性为未核实示例"
    public static let readingGuide = "名称和坐标用来在 Apple 地图上显示公开地点。牵绳、围栏、水源、照片和未定位时的距离都是演示数据。携犬规则未核实，不是许可、风险评级或法律结论。商场的整体信息也不等于每一家店铺。"
    public static let demoBanner = "演示模式 · 未做真实狗证核验 · 不是审核通过"
    public static let screenshotBanner = "调试截图 · 合成示例 · 不是真实证件 · 不是审核通过"
    public static let verifierUnavailable = "核验服务没有接入。正式地图保持锁定。识别文字或保存档案都不会变成审核通过。"
    public static let localParseLabel = "本地解析，不是已连接的语言模型"
    public static let retentionSummary = "原图、完整识别文本、主人姓名、住址、电话、证件号、犬证号和芯片号不会写入本机档案，也不会上传。确认后可以只留下犬名、品种、性别、年龄段和体型等白名单字段，并且可以清除。"
    public static let brandName = "PawTrust"
    public static let brandMark = "爪印识途"
}
