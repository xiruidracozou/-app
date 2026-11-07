import Foundation

public enum ValueOrigin: String, Codable, Equatable, Sendable {
    case userEntered
    case systemInferred
    case empty
}

public struct Attributed<T: Equatable & Codable & Sendable>: Equatable, Codable, Sendable {
    public var value: T?
    public var origin: ValueOrigin

    public init(value: T? = nil, origin: ValueOrigin = .empty) {
        self.value = value
        self.origin = origin
    }

    public static var empty: Attributed<T> { Attributed(value: nil, origin: .empty) }
}

/// Whitelist fields read from license text. There is no slot for an owner, document number, chip, address, phone, image, or raw OCR.
public struct LicenseDraft: Equatable, Sendable {
    public var dogName: Attributed<String>
    public var breed: Attributed<String>
    public var sex: Attributed<String>
    public var ageBand: Attributed<String>
    public var size: Attributed<String>

    public init(
        dogName: Attributed<String> = .empty,
        breed: Attributed<String> = .empty,
        sex: Attributed<String> = .empty,
        ageBand: Attributed<String> = .empty,
        size: Attributed<String> = .empty
    ) {
        self.dogName = dogName
        self.breed = breed
        self.sex = sex
        self.ageBand = ageBand
        self.size = size
    }

    public func asProfile() -> DogProfile {
        var profile = DogProfile.empty
        profile.dogName = dogName
        profile.breed = breed
        profile.sex = sex
        profile.ageBand = ageBand
        profile.size = size
        return profile
    }
}

public enum LicenseExtractor {
    public static func extract(lines: [String], now: Date, calendar: Calendar = .init(identifier: .gregorian)) -> LicenseDraft {
        var draft = LicenseDraft()
        for line in lines where !isSensitive(line) {
            if draft.dogName.value == nil, let name = value(after: ["犬名", "狗名"], in: line) {
                draft.dogName = Attributed(value: name, origin: .systemInferred)
            }
            if draft.breed.value == nil, let breed = value(after: ["品种"], in: line) {
                draft.breed = Attributed(value: breed, origin: .systemInferred)
            }
            if draft.sex.value == nil, let sex = sexValue(line) {
                draft.sex = Attributed(value: sex, origin: .systemInferred)
            }
            if draft.size.value == nil, let size = sizeValue(line) {
                draft.size = Attributed(value: size, origin: .systemInferred)
            }
            if draft.ageBand.value == nil, let band = ageBand(line, now: now, calendar: calendar) {
                draft.ageBand = Attributed(value: band, origin: .systemInferred)
            }
        }
        return draft
    }

    static func isSensitive(_ line: String) -> Bool {
        let markers = ["主人", "畜主", "姓名", "电话", "手机", "住址", "地址", "芯片", "身份证", "证件", "犬证号", "免疫", "编号", "号牌"]
        return markers.contains { line.contains($0) }
    }

    private static func value(after labels: [String], in line: String) -> String? {
        for label in labels {
            guard let range = line.range(of: label) else { continue }
            var rest = line[range.upperBound...]
            rest = rest.drop { $0 == "：" || $0 == ":" || $0 == " " }
            let cleaned = rest.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleaned.isEmpty { return String(cleaned) }
        }
        return nil
    }

    private static func sexValue(_ line: String) -> String? {
        guard line.contains("性别") else { return nil }
        if line.contains("母") { return "母" }
        if line.contains("公") { return "公" }
        return nil
    }

    private static func sizeValue(_ line: String) -> String? {
        guard line.contains("体型") else { return nil }
        if line.contains("小") { return "小型" }
        if line.contains("中") { return "中型" }
        if line.contains("大") { return "大型" }
        return nil
    }

    private static func ageBand(_ line: String, now: Date, calendar: Calendar) -> String? {
        if let years = firstInt(matching: #"(\d{1,2})岁"#, in: line) {
            return band(years: years)
        }
        guard line.contains("出生") || line.contains("年龄") else { return nil }
        guard let year = firstInt(matching: #"(20\d{2})"#, in: line) else { return nil }
        let month = firstInt(matching: #"(\d{1,2})月"#, in: line) ?? 6
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = 15
        guard let birth = calendar.date(from: parts) else { return nil }
        let years = calendar.dateComponents([.year], from: birth, to: now).year ?? 0
        return band(years: max(0, years))
    }

    private static func band(years: Int) -> String {
        switch years {
        case 0: "幼年"
        case 1...2: "青年"
        case 3...8: "成年"
        default: "老年"
        }
    }

    private static func firstInt(matching pattern: String, in line: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range), match.numberOfRanges > 1,
              let slice = Range(match.range(at: 1), in: line) else { return nil }
        return Int(line[slice])
    }
}
