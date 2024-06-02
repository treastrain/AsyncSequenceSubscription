//
//  AsyncSequenceSubscriptionTests.swift
//  AsyncSequenceSubscriptionTests
//
//  Created by treastrain on 2024/06/01.
//

import Foundation

// MARK: - Protocol conformance for testing

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

extension AsyncThrowingStream.Continuation.YieldResult: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.enqueued(let lhsRemaining), .enqueued(let rhsRemaining)):
            return lhsRemaining == rhsRemaining
        case (.terminated, .terminated):
            return true
        case (.dropped(_), _), (_, .dropped(_)):
            fatalError("no implementation")
        default:
            fatalError("no implementation")
        }
    }
}

extension AsyncThrowingStream.Continuation.Termination: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.finished(let lhsFailure), .finished(let rhsFailure)):
            return lhsFailure?.localizedDescription == rhsFailure?.localizedDescription
        case (.cancelled, .cancelled):
            return true
        case (.finished(_), .cancelled), (.cancelled, .finished(_)), (_, _):
            fatalError("no implementation")
        }
    }
}
