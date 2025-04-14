// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HandSynthLibrary",
    products: [
        .library(
            name: "HandSynthLibrary",
            targets: ["HandSynthLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/Tonic.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "HandSynthLibrary",
            dependencies: [
                .product(name: "Tonic", package: "Tonic")
            ],
            resources: [
                .copy("Resources/d5.wav")
            ]
        ),
    ]
)
