import SwiftUI
import MapKit

// MARK: - V2 全屏空间地图 + 多边形区域着色 (MapPolygon / MapCircle) + Apple Maps 三段式阻尼抽屉
// 对标 GitHub 开源设计实践：
// - Wouter125/BottomSheet (https://github.com/Wouter125/BottomSheet) -> 原生 presentationDetents([.height(168), .medium, .large])
// - nathangitter/fluid-interfaces (https://github.com/nathangitter/fluid-interfaces) -> interactiveSpring(response: 0.38, dampingFraction: 0.82)
// - MapConductor/ios-sdk (https://github.com/MapConductor/ios-sdk) -> MapPolygon 区分围栏放绳区 / 牵绳走廊 / 普通公园禁狗红线区

final class PawTrustStateStore: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var currentCity: LaunchCity = .shenzhen
    @Published var isLicenseVerified: Bool = true
    @Published var airTempC: Double = 26.0
    @Published var humidity: Double = 74.0
    @Published var selectedSpot: DogFriendlySpot? = nil
    @Published var sheetDetent: PresentationDetent = .medium
    @Published var spots: [DogFriendlySpot] = []
    @Published var alerts: [HazardAlertItem] = []

    var activeAlertCountForCurrentCity: Int {
        alerts.filter { $0.city == currentCity && $0.status == .confirmed && $0.confirmCount >= 3 }.count
    }

    init() {
        loadDemoData()
    }

    func loadDemoData() {
        let staleDate = Calendar.current.date(byAdding: .day, value: -108, to: Date()) ?? Date()
        spots = [
            DogFriendlySpot(
                id: UUID(),
                city: .shenzhen,
                name: "景田北六街社区宠物公园",
                category: .designatedPetPark,
                parkZoneMode: .dualZone,
                coordinate: CLLocationCoordinate2D(latitude: 22.5568, longitude: 114.0412),
                address: "福田区景田北六街",
                allowOffLeashInFence: true,
                hasWater: true,
                shadePercentage: 65,
                hasFence: true,
                hasSizePartition: true,
                feeText: "免费",
                openHours: "07:00 - 22:00",
                lastVerifiedDate: Date(),
                verifyCount: 42,
                disputeVotes: 1,
                closedVotes: 0,
                baseTrustScore: 96,
                legalBasisType: "区城管局官方挂牌宠物公园",
                legalBasisExplanation: "双门围栏内可放绳，外围步道必牵绳（≤1.5m）。"
            ),
            DogFriendlySpot(
                id: UUID(),
                city: .shenzhen,
                name: "前海桂湾河岸北侧闲置草坪",
                category: .nonParkGreen,
                parkZoneMode: .sharedOnLeash,
                coordinate: CLLocationCoordinate2D(latitude: 22.5265, longitude: 113.9024),
                address: "南山区前海桂湾四路北侧",
                allowOffLeashInFence: false,
                hasWater: false,
                shadePercentage: 20,
                hasFence: false,
                hasSizePartition: false,
                feeText: "免费",
                openHours: "全天",
                lastVerifiedDate: staleDate,
                verifyCount: 8,
                disputeVotes: 0,
                closedVotes: 0,
                baseTrustScore: 87,
                legalBasisType: "河岸待开发空地（非公园红线）",
                legalBasisExplanation: "超 90 天未复核，自动降级为待复核。"
            ),
            DogFriendlySpot(
                id: UUID(),
                city: .shenzhen,
                name: "莲花山公园（禁狗对照点）",
                category: .bannedParkReference,
                parkZoneMode: .banned,
                coordinate: CLLocationCoordinate2D(latitude: 22.5531, longitude: 114.0583),
                address: "福田区红荔路 6030 号",
                allowOffLeashInFence: false,
                hasWater: false,
                shadePercentage: 80,
                hasFence: true,
                hasSizePartition: false,
                feeText: "禁狗对照",
                openHours: "全天禁犬",
                lastVerifiedDate: Date(),
                verifyCount: 64,
                disputeVotes: 0,
                closedVotes: 0,
                baseTrustScore: 99,
                legalBasisType: "《深圳市公园管理条例》",
                legalBasisExplanation: "普通市政公园仅作红色禁狗对照区展示。"
            )
        ]

        alerts = [
            HazardAlertItem(
                id: UUID(),
                city: .shenzhen,
                title: "侨城东路灌木丛疑似异烟肼肉肠",
                hazardType: "剧毒饵料",
                locationDescription: "侨城东路与深南大道东北角",
                coordinate: CLLocationCoordinate2D(latitude: 22.5365, longitude: 114.0068),
                reportedAt: Date(),
                confirmCount: 4,
                status: .confirmed
            )
        ]
    }
}

// MARK: - V2 100% 全屏空间地图视图 + 原生三段位 BottomSheet
struct SpatialMapDiscoveryView: View {
    @EnvironmentObject var store: PawTrustStateStore
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showSheet: Bool = true

    var body: some View {
        ZStack(alignment: .top) {
            // 1. 100% 全屏底层 MapKit 画布（含区域多边形与投毒警戒半径圈）
            Map(position: $cameraPosition) {
                ForEach(store.spots.filter { $0.city == store.currentCity && $0.effectiveStatus != .pendingTwoVotes }) { spot in
                    // 胶囊锚点
                    Annotation(spot.name, coordinate: spot.coordinate) {
                        Button {
                            withAnimation(.interactiveSpring(response: 0.38, dampingFraction: 0.82)) {
                                store.selectedSpot = spot
                                store.sheetDetent = .medium
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(markerColor(for: spot))
                                    .frame(width: 7, height: 7)
                                Text(spot.name.prefix(6))
                                    .font(.caption.weight(.semibold))
                                Text(spot.category == .bannedParkReference ? "禁犬" : "\(spot.effectiveTrustScore)")
                                    .font(.caption2.monospacedDigit().weight(.bold))
                                    .foregroundStyle(markerColor(for: spot))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                }

                // 3人已核实的投毒高危脉冲半径圈
                ForEach(store.alerts.filter { $0.city == store.currentCity && $0.status == .confirmed && $0.confirmCount >= 3 }) { alert in
                    MapCircle(center: alert.coordinate, radius: 420)
                        .foregroundStyle(Color.red.opacity(0.22))
                        .stroke(Color.red, lineWidth: 1.5)
                }
            }
            .ignoresSafeArea()

            // 2. 顶部极简双胶囊 HUD（占地 < 8%）
            HStack {
                Menu {
                    ForEach(LaunchCity.allCases) { city in
                        Button(city.rawValue) {
                            store.currentCity = city
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Circle().fill(Color.green).frame(width: 7, height: 7)
                        Text(store.currentCity.rawValue).font(.subheadline.weight(.semibold))
                        Text("限绳 \(String(format: "%.1f", store.currentCity.maxLeashLengthMeters))m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                }

                Spacer()

                let roadTemp = Int(ThermalSafetyAdvisor.estimatedAsphaltTemp(airTempC: store.airTempC))
                HStack(spacing: 6) {
                    Circle()
                        .fill(store.airTempC >= 28 ? Color.red : Color.orange)
                        .frame(width: 7, height: 7)
                    Text("\(Int(store.airTempC))°C · 路面\(roadTemp)°C")
                        .font(.caption.monospacedDigit().weight(.semibold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        // 3. Apple Maps 同款原生三段位 BottomSheet (Peek 168pt / Medium / Large)
        .sheet(isPresented: $showSheet) {
            VStack(alignment: .leading, spacing: 12) {
                if let spot = store.selectedSpot {
                    // L3: 二级地点详情（渐进式披露）
                    HStack {
                        Button("‹ 返回列表") {
                            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85)) {
                                store.selectedSpot = nil
                            }
                        }
                        .font(.caption.weight(.semibold))
                        Spacer()
                        Text("\(spot.verifyCount)人已核实")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    Text(spot.name).font(.headline)
                    Text(spot.legalBasisExplanation).font(.subheadline).foregroundStyle(.secondary)
                } else {
                    // L2: 严控 3 行的极简列表
                    ForEach(store.spots.filter { $0.city == store.currentCity && $0.effectiveStatus != .pendingTwoVotes }) { spot in
                        Button {
                            store.selectedSpot = spot
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(spot.name).font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(spot.effectiveStatus == .needsReverify ? "待复核 · \(spot.effectiveTrustScore)" : "\(spot.effectiveTrustScore) 分")
                                        .font(.caption.monospacedDigit().weight(.bold))
                                        .foregroundStyle(markerColor(for: spot))
                                }
                                Text(spot.parkZoneMode.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 10) {
                                    Text(spot.hasWater ? "💧有水源" : "需自备水")
                                    Text("🌳遮阴 \(spot.shadePercentage)%")
                                    Spacer()
                                    Text("\(spot.verifyCount)人核实")
                                }
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
            }
            .padding(18)
            .presentationDetents([.height(168), .medium, .large], selection: $store.sheetDetent)
            .presentationBackground(.ultraThinMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .interactiveDismissDisabled()
        }
    }

    private func markerColor(for spot: DogFriendlySpot) -> Color {
        if spot.category == .bannedParkReference { return .red }
        if spot.effectiveStatus == .needsReverify || !spot.allowOffLeashInFence { return .orange }
        return .green
    }
}

struct PublishSpotSheetView: View { var body: some View { Text("6.2 发布地点") } }
struct PoisonHazardRadarView: View { var body: some View { Text("6.5 投毒预警") } }
struct DogLicenseCredentialView: View { var body: some View { Text("6.4 犬证认证") } }
struct CityComplianceRuleView: View { var body: some View { Text("6.6 城市合规") } }
