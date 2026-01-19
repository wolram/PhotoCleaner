// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SnapSieve",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SnapSieve", targets: ["SnapSieve"])
    ],
    targets: [
        .target(
            name: "SnapSieve",
            path: "PhotoCleaner",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Photos")
            ]
        ),
        .testTarget(
            name: "SnapSieveTests",
            dependencies: ["SnapSieve"],
            path: "PhotoCleanerTests"
        )
    ]
)
