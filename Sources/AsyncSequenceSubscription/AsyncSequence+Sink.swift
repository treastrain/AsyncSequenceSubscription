//
//  AsyncSequence+Sink.swift
//  AsyncSequenceSubscription
//
//  Created by treastrain on 2024/06/01.
//

import Foundation

extension AsyncSequence where Self: Sendable {
    @inlinable
    public func sink(
        priority: TaskPriority? = nil,
        @_inheritActorContext receiveValue: @escaping @Sendable (_ element: Element) -> Void,
        @_inheritActorContext receiveCompletion: @escaping @Sendable (_ error: (any Error)?) -> Void = { _ in }
    ) -> Task<(), Never> {
        sink(
            priority: priority,
            receiveValue: { receiveValue($0); return .continue },
            receiveCompletion: receiveCompletion
        )
    }
    
    @_disfavoredOverload
    @inlinable
    public func sink(
        priority: TaskPriority? = nil,
        @_inheritActorContext receiveValue: @escaping @Sendable (_ element: Element) -> AsyncSequenceSubscribers.Sink.Control,
        @_inheritActorContext receiveCompletion: @escaping @Sendable (_ error: (any Error)?) -> Void = { _ in }
    ) -> Task<(), Never> {
        Task(
            priority: priority,
            operation: {
                do {
                    loop: for try await element in self {
                        let control = receiveValue(element)
                        switch control {
                        case .continue: continue loop
                        case .break: break loop
                        }
                    }
                    receiveCompletion(nil)
                } catch {
                    receiveCompletion(error)
                }
            }
        )
    }
    
    @inlinable
    public func sink(
        priority: TaskPriority? = nil,
        @_inheritActorContext receiveValue: @escaping @Sendable (_ element: Element) async -> Void,
        @_inheritActorContext receiveCompletion: @escaping @Sendable (_ error: (any Error)?) async -> Void = { _ in }
    ) -> Task<(), Never> {
        sink(
            priority: priority,
            receiveValue: { await receiveValue($0); return .continue },
            receiveCompletion: receiveCompletion
        )
    }
    
    @_disfavoredOverload
    @inlinable
    public func sink(
        priority: TaskPriority? = nil,
        @_inheritActorContext receiveValue: @escaping @Sendable (_ element: Element) async -> AsyncSequenceSubscribers.Sink.Control,
        @_inheritActorContext receiveCompletion: @escaping @Sendable (_ error: (any Error)?) async -> Void = { _ in }
    ) -> Task<(), Never> {
        Task(
            priority: priority,
            operation: {
                do {
                    loop: for try await element in self {
                        let control = await receiveValue(element)
                        switch control {
                        case .continue: continue loop
                        case .break: break loop
                        }
                    }
                    await receiveCompletion(nil)
                } catch {
                    await receiveCompletion(error)
                }
            }
        )
    }
    
    @inlinable
    public func sinkDetached(
        priority: TaskPriority? = nil,
        receiveValue: @escaping @Sendable (_ element: Element) -> Void,
        receiveCompletion: @escaping @Sendable (_ error: (any Error)?) -> Void = { _ in }
    ) -> Task<(), Never> {
        sinkDetached(
            priority: priority,
            receiveValue: { receiveValue($0); return .continue },
            receiveCompletion: receiveCompletion
        )
    }
    
    @_disfavoredOverload
    @inlinable
    public func sinkDetached(
        priority: TaskPriority? = nil,
        receiveValue: @escaping @Sendable (_ element: Element) -> AsyncSequenceSubscribers.Sink.Control,
        receiveCompletion: @escaping @Sendable (_ error: (any Error)?) -> Void = { _ in }
    ) -> Task<(), Never> {
        Task.detached(
            priority: priority,
            operation: {
                do {
                    loop: for try await element in self {
                        let control = receiveValue(element)
                        switch control {
                        case .continue: continue loop
                        case .break: break loop
                        }
                    }
                    receiveCompletion(nil)
                } catch {
                    receiveCompletion(error)
                }
            }
        )
    }
    
    @inlinable
    public func sinkDetached(
        priority: TaskPriority? = nil,
        receiveValue: @escaping @Sendable (_ element: Element) async -> Void,
        receiveCompletion: @escaping @Sendable (_ error: (any Error)?) async -> Void = { _ in }
    ) -> Task<(), Never> {
        sinkDetached(
            priority: priority,
            receiveValue: { await receiveValue($0); return .continue },
            receiveCompletion: receiveCompletion
        )
    }
    
    @_disfavoredOverload
    @inlinable
    public func sinkDetached(
        priority: TaskPriority? = nil,
        receiveValue: @escaping @Sendable (_ element: Element) async -> AsyncSequenceSubscribers.Sink.Control,
        receiveCompletion: @escaping @Sendable (_ error: (any Error)?) async -> Void = { _ in }
    ) -> Task<(), Never> {
        Task.detached(
            priority: priority,
            operation: {
                do {
                    loop: for try await element in self {
                        let control = await receiveValue(element)
                        switch control {
                        case .continue: continue loop
                        case .break: break loop
                        }
                    }
                    await receiveCompletion(nil)
                } catch {
                    await receiveCompletion(error)
                }
            }
        )
    }
}
