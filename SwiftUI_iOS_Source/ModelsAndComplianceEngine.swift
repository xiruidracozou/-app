import Foundation
import CoreLocation
import CryptoKit

// MARK: - 1. 城市与区域合规模型（一城一策，严禁共用通用规则）
enum LaunchCity: String, CaseIterable, Identifiable {
    case shenzhen = "深圳"
    case beijing = "北京"
    case shanghai = "上海"
    case guangzhou = "广州"
    case hangzhou = "杭州"
    case chengdu = "成都"
    case hongkong = "香港 (候选)"

    var id: String { rawValue }

    var centerCoordinate: CLLocationCoordinate2D {
        switch self {
        case .shenzhen:  return CLLocationCoordinate2D(latitude: 22.5429, longitude: 114.0596)
        case .beijing:   return CLLocationCoordinate2D(latitude: 39.9289, longitude: 116.4403)
        case .shanghai:  return CLLocationCoordinate2D(latitude: 31.2152, longitude: 121.4581)
        case .guangzhou: return CLLocationCoordinate2D(latitude: 23.1191, longitude: 113.3245)
        case .hangzhou:  return CLLocationCoordinate2D(latitude: 30.2592, longitude: 120.1650)
        case .chengdu:   return CLLocationCoordinate2D(latitude: 30.6300, longitude: 104.0750)
        case .hongkong:  return CLLocationCoordinate2D(latitude: 22.3027, longitude: 114.1772)
        }
    }

    var maxLeashLengthMeters: Double {
        switch self {
        case .shanghai, .hongkong: return 2.0
        default: return 1.5
        }
    }

    var bannedBreeds: [String] {
        switch self {
        case .shenzhen:
            return ["比特斗牛梗", "藏獒", "阿根廷杜高犬", "巴西非勒犬", "日本土佐犬", "卡斯罗犬", "罗威纳犬", "德国牧羊犬", "秋田犬", "牛头梗"] // 共38种示例
        case .hongkong:
            return ["比特斗牛梗", "日本土佐犬", "阿根廷杜高犬", "巴西非勒犬"] // Cap. 167D 4类格斗犬
        default:
            return ["比特斗牛梗", "藏獒", "阿根廷杜高犬", "日本土佐犬", "罗威纳犬"]
        }
    }
}

// MARK: - 2. 地点分类与状态机（含 90 天过期降级与 2 人核实门槛）
enum SpotCategory: String, Codable {
    case nonParkGreen = "非公园绿地"     // 需标注法律依据类型与不禁狗原因
    case designatedPetPark = "指定宠物公园" // 需严格区分围栏放绳区 vs 共享牵绳区
    case petFriendlyMerchant = "宠物友好商家" // 需标注是否允许入内、体型限制、牵绳要求
    case bannedParkReference = "普通公园(禁狗对照点)" // 仅作禁狗对照，绝不标为可遛
}

enum PetParkZoneMode: String, Codable {
    case fencedOffLeash = "独立双重门围栏放绳区"
    case sharedOnLeash = "共享牵绳区（严禁放绳）"
    case dualZone = "含围栏放绳区 + 外围共享牵绳区"
    case banned = "全园禁狗对照点"
}

enum SpotVerificationStatus: String, Codable {
    case pendingTwoVotes = "待核实" // 新发布 <2 人核实，不上公开首页
    case verified = "已核实"        // >=2 人核实且 90 天内有复核
    case needsReverify = "待复核"   // 超过 90 天无人复核，信任分降级
    case downgradedOrClosed = "已降级/已关闭"
    case bannedReference = "禁狗对照"
}

struct DogFriendlySpot: Identifiable {
    let id: UUID
    var city: LaunchCity
    var name: String
    var category: SpotCategory
    var parkZoneMode: PetParkZoneMode
    var coordinate: CLLocationCoordinate2D
    var address: String
    var allowOffLeashInFence: Bool
    var hasWater: Bool
    var shadePercentage: Int
    var hasFence: Bool
    var hasSizePartition: Bool
    var feeText: String
    var openHours: String
    var lastVerifiedDate: Date
    var verifyCount: Int
    var disputeVotes: Int
    var closedVotes: Int
    var baseTrustScore: Int
    var legalBasisType: String
    var legalBasisExplanation: String

    // 自动计算距离最后核实天数
    var daysSinceLastVerified: Int {
        Calendar.current.dateComponents([.day], from: lastVerifiedDate, to: Date()).day ?? 0
    }

    // 核心规则：超过 90 天无人复核自动标记为「待复核」且信任分降级
    var effectiveStatus: SpotVerificationStatus {
        if category == .bannedParkReference { return .bannedReference }
        if closedVotes >= 2 || disputeVotes >= 2 { return .downgradedOrClosed }
        if verifyCount < 2 { return .pendingTwoVotes }
        if daysSinceLastVerified > 90 { return .needsReverify }
        return .verified
    }

    var effectiveTrustScore: Int {
        if daysSinceLastVerified > 90 {
            return max(30, baseTrustScore - 35) // 超过90天未复核自动降级
        }
        return min(99, baseTrustScore)
    }
}

// MARK: - 3. 投毒/危险预警模型（需 3 人交叉确认才上首页）
enum HazardAlertStatus: String {
    case pending = "待确认"   // <3人确认
    case confirmed = "已确认" // >=3人交叉确认，上首页顶部横幅
    case resolved = "已处理"
    case debunked = "已辟谣"
}

struct HazardAlertItem: Identifiable {
    let id: UUID
    var city: LaunchCity
    var title: String
    var hazardType: String
    var locationDescription: String
    var coordinate: CLLocationCoordinate2D
    var reportedAt: Date
    var confirmCount: Int
    var status: HazardAlertStatus
}

// MARK: - 4. AI 高温与路面烫伤安全智算引擎（不可替代兽医建议）
struct ThermalSafetyAdvisor {
    /// 根据环境气温估算日照柏油路温度（25°C 气温下路面可达 52°C，60秒烫伤狗爪）
    static func estimatedAsphaltTemp(airTempC: Double) -> Double {
        if airTempC >= 25.0 {
            return 52.0 + (airTempC - 25.0) * 1.8
        }
        return airTempC + max(0, (airTempC - 10.0) * 1.1)
    }

    static func evaluateWalkSafety(airTempC: Double, humidity: Double, isBrachycephalic: Bool) -> (isDanger: Bool, title: String, detail: String) {
        let roadTemp = Int(estimatedAsphaltTemp(airTempC: airTempC))
        if airTempC >= 28.0 {
            return (
                true,
                "🚨 \(Int(airTempC))°C 危险区间 · 请勿外出遛狗",
                "当前估算柏油路面达 \(roadTemp)°C（<60秒即可烫伤狗爪垫），强烈建议停止户外遛狗。注：安全提示不可替代兽医建议。"
            )
        } else if airTempC >= 25.0 {
            return (
                false,
                "⚠️ 气温 \(Int(airTempC))°C · 路面可达 \(roadTemp)°C（60秒烫爪）",
                "日照地面高温，仅建议前往高遮阴草地或空调室内宠物友好商家\(isBrachycephalic ? "（短鼻犬极易中暑，请格外留意）" : "")。"
            )
        } else {
            return (
                false,
                "🌿 气温 \(Int(airTempC))°C · 路面约 \(roadTemp)°C · 适宜出行",
                "气候适宜，AI 已根据遮阴率、水源可靠性及当前城市合规条例为您排序。"
            )
        }
    }
}
