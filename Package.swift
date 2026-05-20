// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GoogleVoiceSwift",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "GoogleVoiceSwift",
            targets: ["GoogleVoiceSwift"]
        )
    ],
    targets: [
        .target(
            name: "GoogleVoiceSwift",
            path: "Sources"
        ),
        .testTarget(
            name: "GoogleVoiceSwiftTests",
            dependencies: ["GoogleVoiceSwift"],
            path: "Tests"
        )
    ]
)
