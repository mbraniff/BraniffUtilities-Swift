// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "BraniffUtilities",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(
            name: "BraniffMacros",
            targets: ["BraniffMacros"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", .upToNextMajor(from: "601.0.1")),
    ],
    targets: [
        .macro(name: "BraniffMacrosImpl", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
        ]),
        .target(name: "BraniffMacros", dependencies: ["BraniffMacrosImpl"])
    ]
)
