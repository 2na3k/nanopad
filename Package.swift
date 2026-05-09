// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NanoPad",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "NanoPad",
            exclude: ["Info.plist"]
        )
    ]
)
