//
//  SynchronizedSet.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 24.02.2021.
//  Copyright © 2021 Rubeg NPO. All rights reserved.
//

import Foundation

class SynchronizedSet<T: Hashable> {
    private var items = Set<T>()

    private let lockQueue = DispatchQueue(
        label: "rubeg_protocol.sync_set",
        qos: .default,
        attributes: .concurrent
    )

    func insert(_ item: T) -> Bool {
        let result = lockQueue.sync {
            self.items.insert(item)
        }

        return result.inserted
    }

    func remove(_ item: T) -> T? {
        return lockQueue.sync {
            self.items.remove(item)
        }
    }

    func contains(_ item: T) -> Bool {
        return lockQueue.sync {
            self.items.contains(item)
        }
    }

    func removeAll() {
        lockQueue.sync {
            self.items.removeAll()
        }
    }
}
