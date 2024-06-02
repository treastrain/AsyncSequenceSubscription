//
//  TaskCancellerStorable+Task.swift
//  TaskCancellerStore
//
//  Created by treastrain on 2024/06/02.
//

import Foundation

extension Task {
    /// Retains the `Task.cancel()` as long as the instance is active (see `Task.isCancelled`). If the instance is deactivated, the `Task.cancel()` is released.
    @discardableResult
    public func storeWhileInstanceActive(
        _ instance: some TaskCancellerStorable
    ) -> Self {
        instance.transientStorage.cancelBag.insert(cancel)
        return self
    }
}
