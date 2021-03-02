// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SQLite",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "SQLite",
            targets: ["SQLite"]),
    ],
    dependencies: [
        .package(name: "Atomic", url: "https://github.com/shareup/Atomic.git", .branch("master")),
        .package(name: "FoundationAdditions", url: "https://github.com/robertgeifman/FoundationAdditions.git", .branch("rc-1")),
    ],
    targets: [
        .target(
            name: "SQLite",
            dependencies: [
                "Atomic",
                "FoundationAdditions",
            ]),
        .testTarget(
            name: "SQLiteTests",
            dependencies: [
                "SQLite",
            ]
        ),
    ]
)
