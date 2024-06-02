//
//  TaskCancellerStorable.swift
//  TaskCancellerStore
//
//  Created by treastrain on 2024/06/02.
//

import Foundation

@_marker public protocol TaskCancellerStorable {}

// MARK: - Default conformance to commonly used types

#if canImport(ObjectiveC)
import ObjectiveC
extension NSObject: TaskCancellerStorable {}
#endif

// MARK: - Transient storage

struct TaskCancellerStorableStorage<Base> {
    final class CancelBag {
        private var cancels: [() -> Void] = []
        
        func insert(_ cancel: @escaping () -> Void) {
            cancels.append(cancel)
        }
        
        deinit {
            cancels.forEach { $0() }
        }
    }
    
    private let base: Base
    
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

private nonisolated(unsafe) var cancelBagKey: UInt8 = 0

extension TaskCancellerStorableStorage {
    var cancelBag: CancelBag {
        sync {
            if let cancelBag = objc_getAssociatedObject(base, &cancelBagKey) as? CancelBag {
                return cancelBag
            } else {
                let cancelBag = CancelBag()
                objc_setAssociatedObject(
                    base,
                    &cancelBagKey,
                    cancelBag,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return cancelBag
            }
        }
    }
    
    private func sync<T>(
        _ operation: () -> T
    ) -> T {
        objc_sync_enter(base)
        let result = operation()
        objc_sync_exit(base)
        return result
    }
}

extension TaskCancellerStorable {
    var transientStorage: TaskCancellerStorableStorage<Self> {
        get { TaskCancellerStorableStorage(self) }
    }
}
