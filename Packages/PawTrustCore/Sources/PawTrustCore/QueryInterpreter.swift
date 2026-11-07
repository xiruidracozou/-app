import Foundation

public struct QueryContext: Equatable, Sendable {
    public var city: City?
    public var category: PlaceCategory?
    public var topics: [RuleTopic]
    public var nearMe: Bool

    public init(city: City? = nil, category: PlaceCategory? = nil, topics: [RuleTopic] = [], nearMe: Bool = false) {
        self.city = city
        self.category = category
        self.topics = topics
        self.nearMe = nearMe
    }

    public var asksAboutRules: Bool { !topics.isEmpty }
}

public struct Interpretation: Equatable, Sendable {
    public var context: QueryContext
    public var unmatched: [String]
    public var label: String
    public var isNameOnly: Bool

    public init(context: QueryContext, unmatched: [String], label: String, isNameOnly: Bool) {
        self.context = context
        self.unmatched = unmatched
        self.label = label
        self.isNameOnly = isNameOnly
    }
}

/// Keyword parser. This is not a language model and does not call a network service.
public struct LocalUtteranceInterpreter: Sendable {
    public static let label = "本地解析"

    public init() {}

    public func interpret(_ text: String, following previous: QueryContext, places: [Place]) -> Interpretation {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return Interpretation(
                context: QueryContext(city: previous.city, category: nil, topics: [], nearMe: false),
                unmatched: [],
                label: Self.label,
                isNameOnly: true
            )
        }
        if let name = places.map(\.name).filter({ trimmed.contains($0) }).max(by: { $0.count < $1.count }) {
            let city = places.first { $0.name == name }?.city ?? previous.city
            return Interpretation(
                context: QueryContext(city: city, category: nil, topics: [], nearMe: false),
                unmatched: [],
                label: Self.label,
                isNameOnly: true
            )
        }

        let fragment = Self.fragmentMarkers.contains { trimmed.contains($0) }
        var parsed = fragment
            ? Parse(city: previous.city, category: previous.category, topics: Set(previous.topics), nearMe: previous.nearMe)
            : Parse(city: nil, category: nil, topics: [], nearMe: false)
        var working = trimmed
        let phrases = Self.phrases.sorted { $0.phrase.count > $1.phrase.count }
        for phrase in phrases {
            let negative = working.contains("不要\(phrase.phrase)") || working.contains("取消\(phrase.phrase)")
            guard working.contains(phrase.phrase) else { continue }
            if negative {
                phrase.remove(&parsed)
            } else {
                phrase.apply(&parsed)
            }
            working = working.replacingOccurrences(of: "不要\(phrase.phrase)", with: " ")
            working = working.replacingOccurrences(of: "取消\(phrase.phrase)", with: " ")
            working = working.replacingOccurrences(of: phrase.phrase, with: " ")
        }
        if !fragment && parsed.nearMe && parsed.city == nil {
            parsed.city = nil
        } else if !fragment && parsed.city == nil && !parsed.nearMe {
            parsed.city = previous.city
        }
        for filler in Self.fillers {
            working = working.replacingOccurrences(of: filler, with: " ")
        }
        let collapsed = working.replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let remainder = collapsed.count >= 2 ? [collapsed] : []
        let topics = RuleTopic.allCases.filter { parsed.topics.contains($0) }
        let context = QueryContext(city: parsed.city, category: parsed.category, topics: topics, nearMe: parsed.nearMe)
        let structured = context.category != nil || context.asksAboutRules || context.nearMe || trimmed.contains("深圳") || trimmed.contains("上海") || fragment
        return Interpretation(
            context: context,
            unmatched: remainder,
            label: Self.label,
            isNameOnly: !structured
        )
    }

    private struct Parse {
        var city: City?
        var category: PlaceCategory?
        var topics: Set<RuleTopic>
        var nearMe: Bool
    }

    private struct Phrase {
        var phrase: String
        var apply: (inout Parse) -> Void
        var remove: (inout Parse) -> Void
    }

    private static let fragmentMarkers = ["改成", "还有", "加上", "也要", "并且", "同时", "不要", "取消"]
    private static let fillers = ["能带", "可以带", "可以", "我想", "一个", "一下", "的", "进", "找", "要", "带", "去", "在", "有", "改成", "还有", "加上", "也要", "并且", "同时", "不要", "取消", "能", "吗"]

    private static let phrases: [Phrase] = [
        Phrase(phrase: "大型犬", apply: { $0.topics.insert(.largeDog) }, remove: { $0.topics.remove(.largeDog) }),
        Phrase(phrase: "大狗", apply: { $0.topics.insert(.largeDog) }, remove: { $0.topics.remove(.largeDog) }),
        Phrase(phrase: "中型犬", apply: { $0.topics.insert(.mediumDog) }, remove: { $0.topics.remove(.mediumDog) }),
        Phrase(phrase: "中狗", apply: { $0.topics.insert(.mediumDog) }, remove: { $0.topics.remove(.mediumDog) }),
        Phrase(phrase: "小型犬", apply: { $0.topics.insert(.smallDog) }, remove: { $0.topics.remove(.smallDog) }),
        Phrase(phrase: "小狗", apply: { $0.topics.insert(.smallDog) }, remove: { $0.topics.remove(.smallDog) }),
        Phrase(phrase: "室内", apply: { $0.topics.insert(.indoor) }, remove: { $0.topics.remove(.indoor) }),
        Phrase(phrase: "围栏", apply: { $0.topics.insert(.fencedArea) }, remove: { $0.topics.remove(.fencedArea) }),
        Phrase(phrase: "放绳", apply: { $0.topics.insert(.offLeash) }, remove: { $0.topics.remove(.offLeash) }),
        Phrase(phrase: "遛狗地", apply: { $0.category = .walking }, remove: { if $0.category == .walking { $0.category = nil } }),
        Phrase(phrase: "遛狗", apply: { $0.category = .walking }, remove: { if $0.category == .walking { $0.category = nil } }),
        Phrase(phrase: "公园", apply: { $0.category = .walking }, remove: { if $0.category == .walking { $0.category = nil } }),
        Phrase(phrase: "餐厅", apply: { $0.category = .dining }, remove: { if $0.category == .dining { $0.category = nil } }),
        Phrase(phrase: "餐馆", apply: { $0.category = .dining }, remove: { if $0.category == .dining { $0.category = nil } }),
        Phrase(phrase: "餐饮", apply: { $0.category = .dining }, remove: { if $0.category == .dining { $0.category = nil } }),
        Phrase(phrase: "吃饭", apply: { $0.category = .dining }, remove: { if $0.category == .dining { $0.category = nil } }),
        Phrase(phrase: "商场", apply: { $0.category = .mall }, remove: { if $0.category == .mall { $0.category = nil } }),
        Phrase(phrase: "购物", apply: { $0.category = .mall }, remove: { if $0.category == .mall { $0.category = nil } }),
        Phrase(phrase: "附近", apply: { $0.nearMe = true }, remove: { $0.nearMe = false }),
        Phrase(phrase: "深圳", apply: { $0.city = .shenzhen }, remove: { if $0.city == .shenzhen { $0.city = nil } }),
        Phrase(phrase: "上海", apply: { $0.city = .shanghai }, remove: { if $0.city == .shanghai { $0.city = nil } }),
    ]
}
