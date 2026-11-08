import SwiftUI
import MapKit
import VisionKit

// MARK: - 爪印识途 (PawTrust) — iOS 18 原生免费路径工程入口
// 架构要点：
// 1. 免费地图底座：使用 Apple 原生 MapKit（中国大陆境内自动合规切换高德 GCJ-02 审图号数据源，香港/海外自动使用 Apple Maps + 康文署 data.gov.hk / OSM Overpass 开放数据，零 API 调用费）。
// 2. 免费端侧 AI：使用 iOS 原生 Vision / VisionKit DataScannerViewController 在设备端本地完成犬证 OCR 提取与 CryptoKit AES-GCM 敏感信息加密存储，无需付费云端 OCR，且注销账号时通过 Keychain & SwiftData 彻底物理擦除。
// 3. 免费气象与热力学智算：直连免密钥 Open-Meteo API 或 WeatherKit 结合柏油路面热辐射模型计算狗爪 60 秒烫伤阈值。

@main
struct PawTrustApp: App {
    @StateObject private var appState = PawTrustStateStore()

    var body: some Scene {
        WindowGroup {
            RootSpatialTabView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootSpatialTabView: View {
    @EnvironmentObject var store: PawTrustStateStore

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $store.selectedTab) {
                SpatialMapDiscoveryView()
                    .tabItem {
                        Label("发现地点", systemImage: "map.fill")
                    }
                    .tag(0)

                PublishSpotSheetView()
                    .tabItem {
                        Label("发布地点", systemImage: "plus.circle.fill")
                    }
                    .tag(1)

                PoisonHazardRadarView()
                    .tabItem {
                        Label("投毒预警", systemImage: "exclamationmark.triangle.fill")
                    }
                    .badge(store.activeAlertCountForCurrentCity)
                    .tag(2)

                DogLicenseCredentialView()
                    .tabItem {
                        Label("犬证认证", systemImage: "person.text.rectangle.fill")
                    }
                    .tag(3)

                CityComplianceRuleView()
                    .tabItem {
                        Label("城市合规", systemImage: "checkmark.shield.fill")
                    }
                    .tag(4)
            }
            .tint(Color(red: 0.06, green: 0.73, blue: 0.51))

            // 顶部全局强制演示免责声明胶囊（严格遵循 PRD 第 11 节）
            Text("⚠️ 演示数据、未核实、不能当法律依据｜高温提示不可替代兽医建议")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.yellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 4)
        }
    }
}
