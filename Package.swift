// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "nexa-code-formatter",
    products: [
        .plugin(name: "format", targets: ["format"]),
    ],
    targets: [
        .plugin(
            name: "format",
            capability: .command(
                intent: .custom(verb: "format", description: "Format source code files"),
                permissions: []
            )
        ),
    ]
)
