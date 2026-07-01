// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ClaudeUsageMenuBar",
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
            name: "ClaudeUsageMenuBar",
            path: "Sources/ClaudeUsageMenuBar"
        ),
        .testTarget(
            name: "ClaudeUsageMenuBarTests",
            dependencies: [
                "ClaudeUsageMenuBar",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/ClaudeUsageMenuBarTests"
        )
    ]
)
