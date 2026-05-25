// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetcatGUI",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "NetcatGUI",
            path: "Sources/NetcatGUI"
        )
    ]
)
