//
//  TaskCancellerStoreTests.swift
//  TaskCancellerStoreTests
//
//  Created by treastrain on 2024/06/02.
//

import XCTest
@testable import TaskCancellerStore

final class TaskCancellerStoreTests: XCTestCase {
    fileprivate final class Object: TaskCancellerStorable {
        var subscriberTask: Task<(), any Error>?
        func subscribe() {
            let (stream, _) = AsyncThrowingStream.makeStream(of: Void.self)
            subscriberTask = Task { [unowned self] in
                for try await _ in stream {}
                try Task.checkCancellation()
                dummy()
            }
            .storeWhileInstanceActive(self)
        }
        
        func dummy() {}
    }
    
    var cancelCallCount = 0
    func testCancelBag() {
        let object = Object()
        object.transientStorage.cancelBag.insert {
            self.cancelCallCount += 1
        }
        addTeardownBlock { [weak object] in
            XCTAssertEqual(self.cancelCallCount, 1)
            XCTAssertNil(object)
        }
    }
    
    func testStorageCancelBag() {
        let object = Object()
        let firstCancelBag = object.transientStorage.cancelBag
        let secondCancelBag = object.transientStorage.cancelBag
        XCTAssertIdentical(firstCancelBag, secondCancelBag)
    }
    
    func testTaskStoreWhileInstanceActive() async throws {
        let object = Object()
        object.subscribe()
        let subscriberTask = try XCTUnwrap(object.subscriberTask)
        addTeardownBlock { [weak object] in
            XCTAssertTrue(subscriberTask.isCancelled)
            XCTAssertNil(object)
        }
    }
}

extension TaskCancellerStoreTests: @unchecked Sendable {}
extension TaskCancellerStoreTests.Object: @unchecked Sendable {}
