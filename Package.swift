// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.0"

let package = Package(
    name: "joyce-platform-ios-sdk",
    platforms: [.iOS(.v15), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "joyce-platform-ios-sdk",
            targets: ["joyce-platform-ios-sdk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "6.27.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.25.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.0")),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "joyce-platform-ios-sdk",
                dependencies: [
                    "Alamofire",
                    "SwiftyJSON",
                    "FirebaseCore",
                    //.product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseDatabaseInternal", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                ],
                plugins: [
                    .plugin(name: "GRDB", package: "grdb.swift"),
                    //.plugin(name: "FirebaseCore", package: "firebase-ios-sdk"),
                    //.plugin(name: "firebase-ios-sdk", package: "firebase-ios-sdk"),
                ]),
        .testTarget(
            name: "joyce-platform-ios-sdkTests",
            dependencies: ["joyce-platform-ios-sdk"]),
    ]
)
