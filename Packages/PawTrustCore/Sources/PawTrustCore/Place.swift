import Foundation

public struct Coordinate: Equatable, Hashable, Sendable, Codable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum Geo {
    /// Great-circle distance on a spherical Earth. Used only to rank example parks
    /// after the person has allowed a one-shot location fix.
    public static func meters(from: Coordinate, to: Coordinate) -> Double {
        let earth = 6_371_000.0
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLat = (to.latitude - from.latitude) * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earth * c
    }
}

public enum LeashPolicy: String, Codable, Equatable, Sendable {
    case required
    case offLeash

    public var title: String {
        switch self {
        case .required: "需牵绳"
        case .offLeash: "可放绳"
        }
    }
}

public enum PlaceFilter: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case offLeash
    case water
    case fenced

    public var title: String {
        switch self {
        case .offLeash: "可放绳"
        case .water: "有水源"
        case .fenced: "有围栏"
        }
    }

    public var symbolName: String {
        switch self {
        case .offLeash: "pawprint.fill"
        case .water: "drop.fill"
        case .fenced: "square.dashed"
        }
    }
}

public struct Place: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: String
    public let name: String
    public let district: String
    public let kindLabel: String
    public let latitude: Double
    public let longitude: Double
    public let leash: LeashPolicy
    public let fenced: Bool
    public let water: Bool
    public let photoName: String
    public let exampleDistanceMeters: Int
    public let blurb: String
    /// Sample parks keep this false. The interface has no “verified” legal state.
    public let rulesVerified: Bool
    public let city: City
    public let category: PlaceCategory
    /// Pet-access statements. Sample data stays unknown; example leash/fence/water flags are separate.
    public let accessRules: [AccessRule]
    /// A place the person added on this device. It is not a published or reviewed listing.
    public let isLocalDraft: Bool

    public var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }

    public var fenceTitle: String { fenced ? "有围栏" : "无围栏" }
    public var waterTitle: String { water ? "有水源" : "无水源" }

    public func matches(_ filter: PlaceFilter) -> Bool {
        switch filter {
        case .offLeash: leash == .offLeash
        case .water: water
        case .fenced: fenced
        }
    }

    public func rule(_ topic: RuleTopic) -> AccessRule? {
        accessRules.first { $0.topic == topic }
    }

    public init(
        id: String,
        name: String,
        district: String,
        kindLabel: String,
        latitude: Double,
        longitude: Double,
        leash: LeashPolicy,
        fenced: Bool,
        water: Bool,
        photoName: String,
        exampleDistanceMeters: Int,
        blurb: String,
        rulesVerified: Bool = false,
        city: City = .shanghai,
        category: PlaceCategory = .walking,
        accessRules: [AccessRule] = [],
        isLocalDraft: Bool = false
    ) {
        self.id = id
        self.name = name
        self.district = district
        self.kindLabel = kindLabel
        self.latitude = latitude
        self.longitude = longitude
        self.leash = leash
        self.fenced = fenced
        self.water = water
        self.photoName = photoName
        self.exampleDistanceMeters = exampleDistanceMeters
        self.blurb = blurb
        self.rulesVerified = rulesVerified
        self.city = city
        self.category = category
        self.accessRules = accessRules
        self.isLocalDraft = isLocalDraft
    }
}

public struct MapRegion: Equatable, Sendable {
    public var center: Coordinate
    public var latitudeDelta: Double
    public var longitudeDelta: Double

    public init(center: Coordinate, latitudeDelta: Double, longitudeDelta: Double) {
        self.center = center
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }

    public func contains(_ coordinate: Coordinate, insetFraction: Double = 0) -> Bool {
        let latHalf = latitudeDelta / 2 * (1 - insetFraction)
        let lonHalf = longitudeDelta / 2 * (1 - insetFraction)
        return abs(coordinate.latitude - center.latitude) <= latHalf
            && abs(coordinate.longitude - center.longitude) <= lonHalf
    }
}

public enum CameraFocus {
    public static let selectionSpanLatitude = 0.03
    public static let selectionSpanLongitude = 0.022
    public static let userSpanLatitude = 0.045
    public static let userSpanLongitude = 0.032

    /// Shifts the camera south so a pin sits above a bottom sheet.
    public static func center(placing coordinate: Coordinate, spanLatitude: Double) -> Coordinate {
        Coordinate(
            latitude: coordinate.latitude - spanLatitude * 0.18,
            longitude: coordinate.longitude
        )
    }
}
