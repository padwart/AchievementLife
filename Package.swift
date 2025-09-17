// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AchievementLife",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AchievementCore",
            targets: ["AchievementCore"]
        )
    ],
    targets: [
        .target(
            name: "AchievementCore"
        ),
        .testTarget(
            name: "AchievementCoreTests",
            dependencies: ["AchievementCore"]
        )
    ]
)
