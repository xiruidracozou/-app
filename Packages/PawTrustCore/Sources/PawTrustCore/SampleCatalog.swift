import Foundation

public enum SampleCatalog {
    /// Approximate public-park coordinates for the Apple map.
    /// They are not a surveyed boundary, and every dog rule on these records is unverified.
    public static let initialRegion = MapRegion(
        center: Coordinate(latitude: 31.21025, longitude: 121.4644),
        latitudeDelta: 0.070,
        longitudeDelta: 0.048
    )

    public static let places: [Place] = [
        Place(
            id: "fuxing",
            name: "复兴公园",
            district: "黄浦",
            kindLabel: "城市公园",
            latitude: 31.2156,
            longitude: 121.4676,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-fuxing",
            exampleDistanceMeters: 650,
            blurb: "示例描述：林荫草坪。是否允许携犬、是否必须牵绳，本应用未核实。",
            rulesVerified: false
        ),
        Place(
            id: "xiangyang",
            name: "襄阳公园",
            district: "徐汇",
            kindLabel: "社区公园",
            latitude: 31.2162,
            longitude: 121.4562,
            leash: .offLeash,
            fenced: true,
            water: false,
            photoName: "place-xiangyang",
            exampleDistanceMeters: 420,
            blurb: "示例描述：小型绿地。可放绳只用于演示筛选，不是园区许可，规则未核实。",
            rulesVerified: false
        ),
        Place(
            id: "jingan",
            name: "静安雕塑公园",
            district: "静安",
            kindLabel: "景观公园",
            latitude: 31.2266,
            longitude: 121.4551,
            leash: .required,
            fenced: true,
            water: true,
            photoName: "place-jingan",
            exampleDistanceMeters: 1_100,
            blurb: "示例描述：草坪与水池。水池不等于宠物饮水处，规则未核实。",
            rulesVerified: false
        ),
        Place(
            id: "renmin",
            name: "人民公园",
            district: "黄浦",
            kindLabel: "市中心公园",
            latitude: 31.2323,
            longitude: 121.4737,
            leash: .required,
            fenced: false,
            water: true,
            photoName: "place-renmin",
            exampleDistanceMeters: 900,
            blurb: "示例描述：靠近人民广场。是否允许携犬未核实。",
            rulesVerified: false
        ),
        Place(
            id: "binjiang",
            name: "徐汇滨江绿地",
            district: "徐汇",
            kindLabel: "河岸步道",
            latitude: 31.1882,
            longitude: 121.4602,
            leash: .required,
            fenced: false,
            water: true,
            photoName: "place-binjiang",
            exampleDistanceMeters: 800,
            blurb: "示例描述：滨江步道。水源只表示附近有河，不代表设有宠物饮水，规则未核实。",
            rulesVerified: false
        ),
    ]
}
