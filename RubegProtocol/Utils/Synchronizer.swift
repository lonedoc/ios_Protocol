//
//  Synchronizer.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 29.10.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class Synchronizer<Key: Hashable> {
    private let keys: Set<Key>
    private let action: () -> Void

    private var receivedKeys = Set<Key>()
    private let lock = NSLock()

    init(keys: Set<Key>, action: @escaping () -> Void) {
        self.keys = keys
        self.action = action
    }

    func synchronize(with key: Key) {
        lock.lock()
        defer { lock.unlock() }

        receivedKeys.insert(key)

        if keys.isSubset(of: keys) {
            action()
            receivedKeys.removeAll()
        }
    }
}
