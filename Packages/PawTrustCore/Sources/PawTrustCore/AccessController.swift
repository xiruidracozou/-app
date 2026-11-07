import Foundation

public enum BuildChannel: String, Codable, Equatable, Sendable {
    case release
    case debug
}

public enum LockReason: String, Codable, Equatable, Sendable {
    case needsLocalProfile
    case profileSavedAwaitingVerification
    case verifierUnavailable
    case verifierRejected
}

public struct VerifierReceipt: Equatable, Codable, Sendable {
    public var issuer: String
    /// A verifier that kept the document is not accepted.
    public var recordsDocument: Bool

    public init(issuer: String, recordsDocument: Bool) {
        self.issuer = issuer
        self.recordsDocument = recordsDocument
    }
}

public enum VerifierDecision: Equatable, Sendable {
    case accepted(VerifierReceipt)
    case rejected
    case unavailable
}

public enum MapAccess: Equatable, Sendable {
    case locked(LockReason)
    case demo(String)
    case verified(VerifierReceipt)

    public var showsMap: Bool {
        switch self {
        case .demo, .verified: true
        case .locked: false
        }
    }
}

public struct UnavailableDogLicenseVerifier: Equatable, Sendable {
    public init() {}

    public func evaluate() -> VerifierDecision {
        .unavailable
    }
}

public enum AccessController {
    public static func initial() -> MapAccess {
        .locked(.needsLocalProfile)
    }

    /// Saving a local profile never unlocks the map.
    public static func afterProfileSaved() -> MapAccess {
        .locked(.profileSavedAwaitingVerification)
    }

    public static func afterVerification(_ decision: VerifierDecision, hasProfile: Bool) -> MapAccess {
        switch decision {
        case .unavailable:
            return .locked(.verifierUnavailable)
        case .rejected:
            return .locked(.verifierRejected)
        case .accepted(let receipt):
            guard hasProfile else { return .locked(.needsLocalProfile) }
            guard !receipt.issuer.isEmpty, receipt.recordsDocument == false else {
                return .locked(.verifierRejected)
            }
            return .verified(receipt)
        }
    }

    /// Debug-only escape. Release ignores it. It is not a verification result.
    public static func afterExplicitDemo(channel: BuildChannel, hasProfile: Bool) -> MapAccess {
        guard channel == .debug, hasProfile else {
            return hasProfile ? .locked(.profileSavedAwaitingVerification) : .locked(.needsLocalProfile)
        }
        return .demo(DemoCopy.demoBanner)
    }

    public static func resolvingLaunch(channel: BuildChannel, hasProfile: Bool, storedDemoFlag: Bool) -> MapAccess {
        guard hasProfile else { return .locked(.needsLocalProfile) }
        if channel == .debug, storedDemoFlag {
            return .demo(DemoCopy.demoBanner)
        }
        return .locked(.profileSavedAwaitingVerification)
    }
}
