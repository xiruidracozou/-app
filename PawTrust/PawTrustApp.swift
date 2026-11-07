import SwiftUI

@main
struct PawTrustApp: App {
    @State private var model: ExploreModel

    init() {
        _model = State(initialValue: ExploreModel())
    }

    var body: some Scene {
        WindowGroup {
            ExploreScreen(model: model)
        }
    }
}
