import XCTest

/// Debug-only screenshots. The app ignores `-PawTrustDemoScreenshots` unless it was built Debug.
final class PawTrustScreenshotTests: XCTestCase {
    func testGateScreenshot() {
        capture(screen: "gate", identifier: "screen.gate", name: "01-gate", settle: 1)
    }

    func testDemoMapScreenshot() {
        capture(screen: "map", identifier: "screen.map", name: "02-demo-map", settle: 4)
    }

    func testDetailScreenshot() {
        capture(screen: "detail", identifier: "screen.detail", name: "03-detail", settle: 4)
    }

    func testProfileScreenshot() {
        capture(screen: "profile", identifier: "screen.profile", name: "04-profile", settle: 1)
    }

    private func capture(screen: String, identifier: String, name: String, settle: TimeInterval) {
        let app = XCUIApplication()
        app.launchArguments = ["-PawTrustDemoScreenshots", screen]
        app.launch()

        let marker = app.descendants(matching: .any)[identifier]
        XCTAssertTrue(
            marker.waitForExistence(timeout: 30),
            "找不到 \(identifier)。Release 构建会忽略调试截图参数，请用 Debug 配置跑这个测试。"
        )
        let banner = app.staticTexts["调试截图 · 合成示例 · 不是真实证件 · 不是审核通过"]
        XCTAssertTrue(banner.waitForExistence(timeout: 5))

        if settle > 0 {
            let pause = XCTNSPredicateExpectation(predicate: NSPredicate(value: true), object: nil)
            _ = XCTWaiter.wait(for: [pause], timeout: settle)
        }

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        if let directory = ProcessInfo.processInfo.environment["PAWTRUST_SCREENSHOT_DIR"], !directory.isEmpty {
            let folder = URL(fileURLWithPath: directory, isDirectory: true)
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent("\(name).png"))
        }
    }
}
