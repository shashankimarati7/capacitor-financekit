// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MeethalfwayCapacitorFinancekit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MeethalfwayCapacitorFinancekit",
            targets: ["FinanceKitPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "FinanceKitPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/FinanceKitPlugin",
            // Apple requires a privacy manifest inside the bundled SDK, and it
            // must be copied into the build, not just present in the repo.
            resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(
            name: "FinanceKitPluginTests",
            dependencies: ["FinanceKitPlugin"],
            path: "ios/Tests/FinanceKitPluginTests")
    ]
)
