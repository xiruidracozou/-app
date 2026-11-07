import Foundation
import PawTrustCore

enum ScreenshotBootstrap {
    #if DEBUG
    /// Synthetic lines for debug screenshots and the debug sample button. Not a real license.
    static let syntheticLines = [
        "犬名：豆豆",
        "品种：贵宾",
        "性别：母",
        "体型：小型",
        "年龄：4岁",
        "主人姓名：合成主人甲",
        "犬证号：SYN000",
        "芯片号：CHIP000",
        "联系电话：00011122233",
        "住址：合成路零号",
    ]

    static func apply(_ request: ScreenshotRequest, to model: ExploreModel) {
        guard AccessController.allowsScreenshotBootstrap(channel: model.channel) else { return }
        let extracted = LicenseExtractor.extract(lines: syntheticLines, now: Date()).asProfile()
        model.screenshotBanner = DemoCopy.screenshotBanner
        model.screenshotRequest = request
        model.draft = extracted
        switch request {
        case .gate:
            model.profile = nil
            model.access = .locked(.needsLocalProfile)
        case .profile:
            model.profile = extracted
            model.access = .locked(.profileSavedAwaitingVerification)
        case .map:
            model.profile = extracted
            model.access = AccessController.afterExplicitDemo(channel: .debug, hasProfile: true)
        case .detail:
            model.profile = extracted
            model.access = AccessController.afterExplicitDemo(channel: .debug, hasProfile: true)
            model.state = ExploreLogic.togglingSelection(model.state, id: "binjiang")
            if let place = model.place("binjiang"), model.state.selectedPlaceID == place.id {
                model.focus(on: place)
            }
        }
    }
    #endif
}
