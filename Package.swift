// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AsyncSequenceSubscription",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
    ],
    targets: [
        .target(
            name: "TaskCancellerStore"),
    ]
)

// Source: https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet
extension SwiftSetting {
    static let forwardTrailingClosures: Self = .enableUpcomingFeature("ForwardTrailingClosures")              // SE-0286, Swift 5.3,  SwiftPM 5.8+
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let bareSlashRegexLiterals: Self = .enableUpcomingFeature("BareSlashRegexLiterals")                // SE-0354, Swift 5.7,  SwiftPM 5.8+
    static let conciseMagicFile: Self = .enableUpcomingFeature("ConciseMagicFile")                            // SE-0274, Swift 5.8,  SwiftPM 5.8+
    static let importObjcForwardDeclarations: Self = .enableUpcomingFeature("ImportObjcForwardDeclarations")  // SE-0384, Swift 5.9,  SwiftPM 5.9+
    static let disableOutwardActorInference: Self = .enableUpcomingFeature("DisableOutwardActorInference")    // SE-0401, Swift 5.9,  SwiftPM 5.9+
    static let deprecateApplicationMain: Self = .enableUpcomingFeature("DeprecateApplicationMain")            // SE-0383, Swift 5.10, SwiftPM 5.10+
    static let isolatedDefaultValues: Self = .enableUpcomingFeature("IsolatedDefaultValues")                  // SE-0411, Swift 5.10, SwiftPM 5.10+
    static let globalConcurrency: Self = .enableUpcomingFeature("GlobalConcurrency")                          // SE-0412, Swift 5.10, SwiftPM 5.10+
    static let strictConcurrency: Self = .enableExperimentalFeature("StrictConcurrency")
}

extension SwiftSetting: CaseIterable {
    public static var allCases: [Self] { [
        .forwardTrailingClosures,
        .existentialAny,
        .bareSlashRegexLiterals,
        .conciseMagicFile,
        .importObjcForwardDeclarations,
        .disableOutwardActorInference,
        .deprecateApplicationMain,
        .isolatedDefaultValues,
        .globalConcurrency,
        .strictConcurrency,
    ] }
}

package.targets
    .forEach { $0.swiftSettings = SwiftSetting.allCases }
