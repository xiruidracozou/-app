import SwiftUI
import PawTrustCore

@main
struct PawTrustApp: App {
    @State private var model: ExploreModel

    init() {
        #if DEBUG
        let channel = BuildChannel.debug
        #else
        let channel = BuildChannel.release
        #endif
        _model = State(initialValue: ExploreModel(channel: channel))
    }

    var body: some Scene {
        WindowGroup {
            PawTrustRoot(model: model)
        }
    }
}

struct PawTrustRoot: View {
    @Bindable var model: ExploreModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if model.access.showsMap {
                ExploreScreen(model: model)
            } else {
                GateScreen(model: model)
            }
        }
        .overlay {
            if scenePhase != .active && model.holdsSensitiveMaterial {
                PrivacyCover()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                model.discardSensitiveMaterial()
            }
        }
    }
}
