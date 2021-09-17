// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "core-networking",
    platforms: [
        .iOS(.v14),
//        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CoreNetworking",
            targets: ["CoreNetworking"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.4.0"),
        // NOTE: For some reason, this CasePaths dependency has to be declared without the ".git" extension.
        // - if the extension is present, the compilation of the package fails with "Missing module CasePaths"
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.7.0"),
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", from: "1.0.0"),
        .package(name: "Overture", url: "https://github.com/pointfreeco/swift-overture.git", from: "0.5.0"),
        .package(name: "core", url: "https://github.com/Qase/swift-core.git", .branch("master")),
        .package(name: "overture-operators", url: "https://github.com/Qase/swift-overture-operators.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreNetworking",
            dependencies: [
                "Overture",
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "Core", package: "core"),
                .product(name: "OvertureOperators", package: "overture-operators"),
                "CombineExt"
            ]
        ),
        .testTarget(
            name: "CoreNetworkingTests",
            dependencies: [
                "CoreNetworking",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
    ]
)
