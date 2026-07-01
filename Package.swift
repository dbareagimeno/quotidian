// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Quotidian",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        // The Swift 6 toolchain claims to bundle Testing, but on this
        // Command Line Tools-only install `import Testing` fails with
        // "missing required module '_TestingInternals'". Pulling the
        // standalone package works around that gap.
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0")
    ],
    targets: [
        .executableTarget(
            name: "Quotidian",
            path: "Sources/Quotidian"
        ),
        .testTarget(
            name: "QuotidianTests",
            dependencies: [
                "Quotidian",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/QuotidianTests"
        )
    ]
)
