// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PhotoCleaner",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "PhotoCleaner", targets: ["PhotoCleaner"])
    ],
    targets: [
        .target(
            name: "PhotoCleaner",
            path: "PhotoCleaner",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Photos")
            ]
        ),
        .testTarget(
            name: "PhotoCleanerTests",
            dependencies: ["PhotoCleaner"],
            path: "PhotoCleanerTests"
        )
    ]
)
