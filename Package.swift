// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "moo",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.114.0")
    ],
    targets: [
        .executableTarget(
            name: "moo",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        )
    ]
)
