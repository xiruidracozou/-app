// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PawTrustCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "PawTrustCore", type: .static, targets: ["PawTrustCore"]),
    ],
    targets: [
        .target(name: "PawTrustCore"),
        .testTarget(name: "PawTrustCoreTests", dependencies: ["PawTrustCore"]),
    ]
)
