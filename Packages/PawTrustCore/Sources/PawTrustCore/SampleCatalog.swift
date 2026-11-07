import Foundation

public enum SampleCatalog {
    /// Approximate public-park coordinates for the Apple map.
    /// They are not a surveyed boundary, and every dog rule on these records is unverified.
    public static let initialRegion = MapRegion(
        center: Coordinate(latitude: 31.21025, longitude: 121.4644),
        latitudeDelta: 0.070,
        longitudeDelta: 0.048
    )

    public static let shenzhenRegion = MapRegion(
        center: Coordinate(latitude: 22.532, longitude: 114.001),
        latitudeDelta: 0.070,
        longitudeDelta: 0.160
    )

    public static func region(for city: City) -> MapRegion {
        switch city {
        case .shanghai: initialRegion
        case .shenzhen: shenzhenRegion
        }
    }

    public static func places(in city: City) -> [Place] {
        places.filter { $0.city == city }
    }

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
            rulesVerified: false,
            city: .shanghai,
            category: .walking,
            accessRules: SampleRules.baseline(mentionsStores: false)
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
            rulesVerified: false,
            city: .shanghai,
            category: .walking,
            accessRules: SampleRules.baseline(mentionsStores: false)
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
            rulesVerified: false,
            city: .shanghai,
            category: .walking,
            accessRules: SampleRules.baseline(mentionsStores: false)
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
            rulesVerified: false,
            city: .shanghai,
            category: .walking,
            accessRules: SampleRules.baseline(mentionsStores: false)
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
            rulesVerified: false,
            city: .shanghai,
            category: .walking,
            accessRules: SampleRules.baseline(mentionsStores: false)
        ),
        Place(
            id: "iapm",
            name: "上海环贸iapm",
            district: "徐汇",
            kindLabel: "商场",
            latitude: 31.2168,
            longitude: 121.4580,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-renmin",
            exampleDistanceMeters: 700,
            blurb: "商场候选示例。是否允许携犬未核实，也不等于商场里每一家店都允许。",
            rulesVerified: false,
            city: .shanghai,
            category: .mall,
            accessRules: SampleRules.baseline(mentionsStores: true)
        ),
        Place(
            id: "deda",
            name: "德大西菜社",
            district: "黄浦",
            kindLabel: "餐饮候选",
            latitude: 31.2348,
            longitude: 121.4840,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-fuxing",
            exampleDistanceMeters: 500,
            blurb: "餐饮候选示例。是否允许携犬、体型限制和室内范围都未核实。",
            rulesVerified: false,
            city: .shanghai,
            category: .dining,
            accessRules: SampleRules.baseline(mentionsStores: false)
        ),
        Place(
            id: "lianhuashan",
            name: "莲花山公园",
            district: "福田",
            kindLabel: "城市公园",
            latitude: 22.5535,
            longitude: 114.0580,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-xiangyang",
            exampleDistanceMeters: 900,
            blurb: "深圳遛狗地候选。是否允许携犬未核实。",
            rulesVerified: false,
            city: .shenzhen,
            category: .walking,
            accessRules: SampleRules.baseline(mentionsStores: false)
        ),
        Place(
            id: "szbay",
            name: "深圳湾公园",
            district: "南山",
            kindLabel: "滨海公园",
            latitude: 22.5180,
            longitude: 113.9720,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-binjiang",
            exampleDistanceMeters: 1_200,
            blurb: "深圳滨海绿地候选。坐标是公园范围内的一个示意点。是否允许携犬未核实。",
            rulesVerified: false,
            city: .shenzhen,
            category: .walking,
            accessRules: SampleRules.baseline(mentionsStores: false)
        ),
        Place(
            id: "sz-mixc",
            name: "深圳湾万象城",
            district: "南山",
            kindLabel: "商场",
            latitude: 22.5096,
            longitude: 113.9436,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-jingan",
            exampleDistanceMeters: 1_500,
            blurb: "商场候选示例。整体是否允许携犬未核实，也不等于每一家店铺允许。",
            rulesVerified: false,
            city: .shenzhen,
            category: .mall,
            accessRules: SampleRules.baseline(mentionsStores: true)
        ),
        Place(
            id: "sz-mixc-dining",
            name: "深圳湾万象城餐饮层",
            district: "南山",
            kindLabel: "餐饮层",
            latitude: 22.5102,
            longitude: 113.9442,
            leash: .required,
            fenced: false,
            water: false,
            photoName: "place-jingan",
            exampleDistanceMeters: 1_500,
            blurb: "商场餐饮层候选，不是某一家店的准入。室内和大型犬规则都未核实。",
            rulesVerified: false,
            city: .shenzhen,
            category: .dining,
            accessRules: SampleRules.baseline(mentionsStores: true)
        ),
    ]
}
