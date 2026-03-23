// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AppUninstaller",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "AppUninstaller",
            path: "Sources"
        )
    ]
)
