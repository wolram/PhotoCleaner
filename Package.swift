// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PhotoCleaner",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PhotoCleaner", targets: ["PhotoCleaner"])
    ],
    targets: [
        .executableTarget(
            name: "PhotoCleaner",
            path: "PhotoCleaner"
        ),
        .testTarget(
            name: "PhotoCleanerTests",
            dependencies: ["PhotoCleaner"],
            path: "PhotoCleanerTests"
        )
    ]
)
