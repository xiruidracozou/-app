import Foundation

public enum City: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case shanghai
    case shenzhen

    public var title: String {
        switch self {
        case .shanghai: "上海"
        case .shenzhen: "深圳"
        }
    }
}

public enum PlaceCategory: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case walking
    case dining
    case mall

    public var title: String {
        switch self {
        case .walking: "遛狗地"
        case .dining: "餐饮"
        case .mall: "商场"
        }
    }
}

public enum RuleTopic: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case petEntry
    case indoor
    case largeDog
    case mediumDog
    case smallDog
    case fencedArea
    case offLeash
    case eachStore

    public var title: String {
        switch self {
        case .petEntry: "是否允许携犬"
        case .indoor: "室内"
        case .largeDog: "大型犬"
        case .mediumDog: "中型犬"
        case .smallDog: "小型犬"
        case .fencedArea: "围栏"
        case .offLeash: "可放绳"
        case .eachStore: "每一家店铺"
        }
    }
}

public enum RuleValue: String, Codable, Equatable, Hashable, Sendable {
    case unknown
    case statedAllowed
    case statedRestricted
    case conflict
    case confirmedAllowed
    case confirmedRestricted

    public var countsAsSatisfied: Bool {
        self == .confirmedAllowed
    }

    public var contradictsRequest: Bool {
        self == .statedRestricted || self == .confirmedRestricted
    }
}

public struct AccessRule: Equatable, Hashable, Sendable, Codable {
    public var topic: RuleTopic
    public var value: RuleValue
    public var condition: String
    public var source: String
    public var lastConfirmedAt: Date?

    public init(
        topic: RuleTopic,
        value: RuleValue,
        condition: String,
        source: String,
        lastConfirmedAt: Date? = nil
    ) {
        self.topic = topic
        self.value = value
        self.condition = condition
        self.source = source
        self.lastConfirmedAt = lastConfirmedAt
    }
}

public enum SampleRules {
    public static let source = "官方整理的基础地点"

    public static func baseline(mentionsStores: Bool) -> [AccessRule] {
        var rules = [
            AccessRule(topic: .petEntry, value: .unknown, condition: "是否允许携犬未核实", source: source),
            AccessRule(topic: .indoor, value: .unknown, condition: "室内范围未核实", source: source),
            AccessRule(topic: .largeDog, value: .unknown, condition: "体型限制未核实", source: source),
            AccessRule(topic: .fencedArea, value: .unknown, condition: "围栏情况未核实", source: source),
            AccessRule(topic: .offLeash, value: .unknown, condition: "能否放绳未核实", source: source),
        ]
        if mentionsStores {
            rules.append(
                AccessRule(
                    topic: .eachStore,
                    value: .unknown,
                    condition: "商场或场地的整体信息不等于每一家店铺的准入",
                    source: source
                )
            )
        }
        return rules
    }
}

public enum MatchBucket: String, Equatable, Sendable {
    case matched
    case unknown
    case excluded
}

public struct PlaceAssessment: Equatable, Sendable {
    public var placeID: String
    public var bucket: MatchBucket
    public var lines: [String]

    public init(placeID: String, bucket: MatchBucket, lines: [String]) {
        self.placeID = placeID
        self.bucket = bucket
        self.lines = lines
    }
}

public enum MatchCopy {
    public static let unknownNotSatisfied = "未知，不能当作满足"
    public static let statedNotSatisfied = "只有说法，没有确认，不能当作满足"
    public static let conflictShown = "有冲突记录，不会用一条说法覆盖"
    public static let missingTime = "没有确认时间，不能当作满足"
}

public enum RuleMatcher {
    public static func assess(place: Place, topics: [RuleTopic]) -> PlaceAssessment {
        var satisfied: [String] = []
        var unknown: [String] = []
        var contradicted: [String] = []
        for topic in topics {
            let rule = place.rule(topic)
            let value = rule?.value ?? .unknown
            let title = topic.title
            if value.contradictsRequest {
                contradicted.append("\(title)：与所问条件相反")
            } else if value == .confirmedAllowed, rule?.lastConfirmedAt != nil {
                let when = rule?.lastConfirmedAt.map { MatchCopy.confirmedLine(title: title, rule: $0, condition: rule?.condition ?? "") } ?? ""
                satisfied.append(when)
            } else if value == .confirmedAllowed {
                unknown.append("\(title)：\(MatchCopy.missingTime)")
            } else if value == .conflict {
                unknown.append("\(title)：\(MatchCopy.conflictShown)")
            } else if value == .statedAllowed {
                unknown.append("\(title)：\(MatchCopy.statedNotSatisfied)")
            } else {
                unknown.append("\(title)：\(MatchCopy.unknownNotSatisfied)")
            }
        }
        let bucket: MatchBucket
        if !contradicted.isEmpty {
            bucket = .excluded
        } else if unknown.isEmpty {
            bucket = .matched
        } else {
            bucket = .unknown
        }
        return PlaceAssessment(placeID: place.id, bucket: bucket, lines: satisfied + unknown + contradicted)
    }

    public static func split(places: [Place], topics: [RuleTopic]) -> (matched: [PlaceAssessment], unknown: [PlaceAssessment], excluded: [PlaceAssessment]) {
        var matched: [PlaceAssessment] = []
        var unknown: [PlaceAssessment] = []
        var excluded: [PlaceAssessment] = []
        for place in places {
            let assessment = assess(place: place, topics: topics)
            switch assessment.bucket {
            case .matched: matched.append(assessment)
            case .unknown: unknown.append(assessment)
            case .excluded: excluded.append(assessment)
            }
        }
        return (matched, unknown, excluded)
    }
}

extension MatchCopy {
    static func confirmedLine(title: String, rule date: Date, condition: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: date)
        if condition.isEmpty {
            return "\(title)：已确认允许（\(day)）"
        }
        return "\(title)：已确认允许（\(day)）。条件：\(condition)"
    }
}
