// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
	name: "Forwarding",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
		.macCatalyst(.v13),
	],
	products: [
		.library(
			name: "Forwarding",
			targets: ["Forwarding"]
		),
		.executable(
			name: "ForwardingSample",
			targets: ["ForwardingSample"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0"),
	],
	targets: [
		.macro(
			name: "ForwardingMacros",
			dependencies: [
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
			]
		),
		.target(name: "Forwarding", dependencies: ["ForwardingMacros"]),
		.executableTarget(name: "ForwardingSample", dependencies: ["Forwarding"]),
		.testTarget(
			name: "ForwardingTests",
			dependencies: [
				"ForwardingMacros",
				.product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
			]
		),
	]
)
