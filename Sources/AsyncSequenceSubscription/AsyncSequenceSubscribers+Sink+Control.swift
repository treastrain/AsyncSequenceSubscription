//
//  AsyncSequenceSubscribers+Sink+Control.swift
//  AsyncSequenceSubscription
//
//  Created by treastrain on 2024/06/01.
//

import Foundation

extension AsyncSequenceSubscribers.Sink {
    public enum Control: CaseIterable, Sendable {
        case `continue`
        case `break`
    }
}
