//
//  AsyncSequenceSinkAsyncVoidTests.swift
//  AsyncSequenceSubscriptionTests
//
//  Created by treastrain on 2024/06/01.
//

import XCTest
@testable import AsyncSequenceSubscription

final class AsyncSequenceSinkAsyncVoidTests: XCTestCase {
    private let (stream, continuation) = AsyncThrowingStream.makeStream(of: Int.self)
    
    private var termination: AsyncThrowingStream<Int, any Error>.Continuation.Termination?
    private var receivedValues: [Int?] = []
    private var receivedCompletions: [(any Error)?] = []
    
    // MARK: - sink - async - Void - success
    func testSuccess() async {
        let onTerminationExpectation = expectation(description: "on termination")
        let receiveValueExpectation = expectation(description: "receive value")
        receiveValueExpectation.expectedFulfillmentCount = 2
        let receiveCompletionExpectation = expectation(description: "receive completion")
        continuation.onTermination = {
            self.termination = $0
            onTerminationExpectation.fulfill()
        }
        let task = stream.sink(
            priority: nil,
            receiveValue: {
                self.receivedValues.append($0)
                receiveValueExpectation.fulfill()
                await Task.yield()
            },
            receiveCompletion: {
                self.receivedCompletions.append($0)
                receiveCompletionExpectation.fulfill()
            }
        )
        let result0 = continuation.yield(10)
        XCTAssertEqual(result0, .enqueued(remaining: .max))
        let result1 = continuation.yield(11)
        XCTAssertEqual(result1, .enqueued(remaining: .max))
        await fulfillment(of: [receiveValueExpectation], timeout: 0.01)
        XCTAssertEqual(receivedValues, [10, 11])
        task.cancel()
        XCTAssertTrue(task.isCancelled)
        await fulfillment(of: [onTerminationExpectation, receiveCompletionExpectation], timeout: 0.01)
        XCTAssertEqual(termination, .cancelled)
        XCTAssertEqual(receivedCompletions.map({ $0?.localizedDescription }), [nil])
    }
    
    // MARK: - sink - async - Void - failure
    func testFailure() async {
        let onTerminationExpectation = expectation(description: "on termination")
        let receiveValueExpectation = expectation(description: "receive value")
        let receiveCompletionExpectation = expectation(description: "receive completion")
        continuation.onTermination = {
            self.termination = $0
            onTerminationExpectation.fulfill()
        }
        let task = stream.sink(
            priority: nil,
            receiveValue: {
                self.receivedValues.append($0)
                receiveValueExpectation.fulfill()
                await Task.yield()
            },
            receiveCompletion: {
                self.receivedCompletions.append($0)
                receiveCompletionExpectation.fulfill()
            }
        )
        let result = continuation.yield(20)
        XCTAssertEqual(result, .enqueued(remaining: .max))
        continuation.finish(throwing: #function)
        await fulfillment(of: [receiveValueExpectation], timeout: 0.01)
        XCTAssertEqual(receivedValues, [20])
        task.cancel()
        XCTAssertTrue(task.isCancelled)
        await fulfillment(of: [onTerminationExpectation, receiveCompletionExpectation], timeout: 0.01)
        XCTAssertEqual(termination, .finished(#function))
        XCTAssertEqual(receivedCompletions.map({ $0?.localizedDescription }), [#function.localizedDescription])
    }
    
    // MARK: - sink - async - Void - failure (with default implementation)
    func testFailureWithDefaultImplementation() async {
        let onTerminationExpectation = expectation(description: "on termination")
        let receiveValueExpectation = expectation(description: "receive value")
        continuation.onTermination = {
            self.termination = $0
            onTerminationExpectation.fulfill()
        }
        let task = stream.sink(
            priority: nil,
            receiveValue: {
                self.receivedValues.append($0)
                receiveValueExpectation.fulfill()
                await Task.yield()
            }
        )
        let result = continuation.yield(30)
        XCTAssertEqual(result, .enqueued(remaining: .max))
        continuation.finish(throwing: #function)
        await fulfillment(of: [receiveValueExpectation], timeout: 0.01)
        XCTAssertEqual(receivedValues, [30])
        task.cancel()
        XCTAssertTrue(task.isCancelled)
        await fulfillment(of: [onTerminationExpectation], timeout: 0.01)
        XCTAssertEqual(termination, .finished(#function))
    }
}

extension AsyncSequenceSinkAsyncVoidTests: @unchecked Sendable {}
