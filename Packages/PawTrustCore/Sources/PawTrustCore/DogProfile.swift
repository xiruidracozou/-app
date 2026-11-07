import Foundation

public struct DogProfile: Equatable, Codable, Sendable {
    public var dogName: Attributed<String>
    public var breed: Attributed<String>
    public var sex: Attributed<String>
    public var ageBand: Attributed<String>
    public var size: Attributed<String>
    public var temperament: Attributed<String>
    public var sociability: Attributed<String>
    public var outing: Attributed<String>
    public var learningEnabled: Bool

    public init(
        dogName: Attributed<String> = .empty,
        breed: Attributed<String> = .empty,
        sex: Attributed<String> = .empty,
        ageBand: Attributed<String> = .empty,
        size: Attributed<String> = .empty,
        temperament: Attributed<String> = .empty,
        sociability: Attributed<String> = .empty,
        outing: Attributed<String> = .empty,
        learningEnabled: Bool = false
    ) {
        self.dogName = dogName
        self.breed = breed
        self.sex = sex
        self.ageBand = ageBand
        self.size = size
        self.temperament = temperament
        self.sociability = sociability
        self.outing = outing
        self.learningEnabled = learningEnabled
    }

    public static let empty = DogProfile()

    public var hasAnyPetFact: Bool {
        [dogName.value, breed.value, sex.value, ageBand.value, size.value, temperament.value, sociability.value, outing.value]
            .contains { ($0 ?? "").isEmpty == false }
    }

    public func settingLearning(_ enabled: Bool) -> DogProfile {
        var copy = self
        copy.learningEnabled = enabled
        guard !enabled else { return copy }
        copy.dogName = clearedIfInferred(copy.dogName)
        copy.breed = clearedIfInferred(copy.breed)
        copy.sex = clearedIfInferred(copy.sex)
        copy.ageBand = clearedIfInferred(copy.ageBand)
        copy.size = clearedIfInferred(copy.size)
        copy.temperament = clearedIfInferred(copy.temperament)
        copy.sociability = clearedIfInferred(copy.sociability)
        copy.outing = clearedIfInferred(copy.outing)
        return copy
    }

    public func learning(from context: QueryContext) -> DogProfile {
        guard learningEnabled else { return self }
        var copy = self
        if copy.size.origin != .userEntered, let size = Self.sizeSuggestion(context.topics) {
            copy.size = Attributed(value: size, origin: .systemInferred)
        }
        if copy.outing.origin != .userEntered {
            if context.category == .walking, context.nearMe {
                copy.outing = Attributed(value: "日常遛狗", origin: .systemInferred)
            } else if context.category == .dining || context.category == .mall {
                copy.outing = Attributed(value: "周末出行", origin: .systemInferred)
            }
        }
        return copy
    }

    private func clearedIfInferred(_ field: Attributed<String>) -> Attributed<String> {
        field.origin == .systemInferred ? .empty : field
    }

    private static func sizeSuggestion(_ topics: [RuleTopic]) -> String? {
        if topics.contains(.largeDog) { return "大型" }
        if topics.contains(.mediumDog) { return "中型" }
        if topics.contains(.smallDog) { return "小型" }
        return nil
    }
}

public enum ProfileLearning {
    public static func apply(search context: QueryContext, to profile: DogProfile) -> DogProfile {
        profile.learning(from: context)
    }
}
