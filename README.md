# AsyncSequenceSubscription
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/treastrain/AsyncSequenceSubscription/blob/main/LICENSE)
![Swift: 5.10](https://img.shields.io/badge/Swift-5.10-orange.svg)
![Platform: iOS & iPadOS|macOS|tvOS|watchOS|visionOS|Linux|Windows](https://img.shields.io/badge/Platform-iOS%20%26%20iPadOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager) \
[![Swift - Build and Test](https://github.com/treastrain/AsyncSequenceSubscription/actions/workflows/swift.yml/badge.svg)](https://github.com/treastrain/AsyncSequenceSubscription/actions/workflows/swift.yml)
[![Xcode - Build, Analyze and Test](https://github.com/treastrain/AsyncSequenceSubscription/actions/workflows/xcodebuild.yml/badge.svg)](https://github.com/treastrain/AsyncSequenceSubscription/actions/workflows/xcodebuild.yml)

This library aims to minimize the common mistakes that occur when receiving Swift Concurrency `AsyncSequence` elements using the `for-await-in` syntax.

**Before 😿**
```swift
import Foundation

let sequence: some AsyncSequence = ...

let task = Task {
    for try await element in sequence {
        await didReceived(element)
    }
}
```

**After 😊**
```swift
import AsyncSequenceSubscription
import Foundation

let sequence: some AsyncSequence = ...

sequence
    .sink { [weak self] element in
        await self?.didReceived(element)
    }
    .storeWhileInstanceActive(self)
```

## Adding AsyncSequenceSubscription as a Dependency
To use this library in a Swift Package Manager project, add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/treastrain/AsyncSequenceSubscription", from: "0.1.0"),
```

Include "AsyncSequenceSubscription" as a dependency for your executable target:

```swift
.target(name: "<target>", dependencies: [
    .product(name: "AsyncSequenceSubscription", package: "AsyncSequenceSubscription"),
]),
```

Finally, add `import AsyncSequenceSubscription` to your source code.

## Details
The following code is written to subscribe to elements of an `AsyncSequence`.

```swift
import Foundation

final class AlphaObject {
    var task: Task<(), any Error>?
    
    init() {
        print("✅", "AlphaObject", "is inited")
    }
    
    deinit {
        task?.cancel()
        print("✅", "AlphaObject", "is deinited")
    }
    
    func subscribe() async throws {
        let (stream, _) = AsyncThrowingStream.makeStream(of: Void.self)
        task = Task {
            for try await element in stream {
                await didReceived()
            }
        }
    }
    
    func didReceived() async { /* ... */ }
}

do {
    let alpha = AlphaObject()
    try? await alpha.subscribe()
}

/*
 ✅ AlphaObject is inited
 (But "✅ AlphaObject is deinited" is not printed...)
 */
```

The `task` is designed to be cancelled when its instance is deactivated. However, the deinitializer of the `AlphaObject` instance isn't invoked even when it's no longer in use, leading to the `task` not being cancelled and causing memory leaks. This issue arises due to the `@_implicitSelfCapture` attribute applied to `operation`, the second argument of the `Task` initializer. This attribute implicitly captures `self` by a strong reference for the `didReceived()` method called within the `for-await-in` loop. This pitfall can be challenging to detect as it doesn't generate compile-time warnings or errors.

Let's utilize this library to minimize the likelihood of encountering this issue!

```swift
import AsyncSequenceSubscription
import Foundation

final class BravoObject {
    init() {
        print("✅", "BravoObject", "is inited")
    }
    
    deinit {
        print("✅", "BravoObject", "is deinited")
    }
    
    func subscribe() async throws {
        let (stream, _) = AsyncThrowingStream.makeStream(of: Void.self)
        stream
            .sink { [weak self] element in
                await self?.didReceived()
            }
            .storeWhileInstanceActive(self)
    }
    
    func didReceived() async { /* ... */ }
}

extension BravoObject: TaskCancellerStorable {}

do {
    let bravo = BravoObject()
    try? await bravo.subscribe()
}

/*
 ✅ BravoObject is inited
 ✅ BravoObject is deinited
 */
```

You can employ a syntax akin to the `sink` provided by Apple's Combine. This eliminates the need to worry about implicitly capturing `self`, and allows you to invoke asynchronous methods within the closure. Furthermore, when used on Apple platforms, you can pair it with `storeWhileInstanceActive(_:)` to immediately cancel the `AsyncSequence` subscription once the instance is released.
