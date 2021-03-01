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
        .package(name: "Atomic", path: "../atomic"),
        .package(name: "FoundationAdditions", path: "../FoundationAdditions"),
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
