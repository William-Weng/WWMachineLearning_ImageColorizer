// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWMachineLearning_ImageColorizer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "WWMachineLearning_ImageColorizer", targets: ["WWMachineLearning_ImageColorizer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWMachineLearning_Resnet50", from: "1.1.2")
    ],
    targets: [
        .target(name: "WWMachineLearning_ImageColorizer", dependencies: ["WWMachineLearning_Resnet50", "CLittleCMS"], resources: [.copy("Privacy"), .process("ICC")]),
        .target(name: "CLittleCMS", dependencies: [], path: "Sources/CLittleCMS", sources: ["littlecms"], publicHeadersPath: "littlecms")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
