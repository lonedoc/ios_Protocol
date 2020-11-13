//
//  Queue.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 27.10.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

private let lockQueueLabel = "rubeg_protocol.queue"

class Queue<T> {
    private var items = LinkedList<T>()

    private let lockQueue = DispatchQueue(
        label: lockQueueLabel,
        qos: .default,
        attributes: .concurrent
    )

    func enqueue(_ item: T) {
        lockQueue.sync(flags: .barrier) {
            self.items.add(item)
        }
    }

    func dequeue() -> T? {
        return lockQueue.sync(flags: .barrier) {
            self.items.removeFirst()
        }
    }

    func clear() {
        lockQueue.sync(flags: .barrier) {
            self.items.clear()
        }
    }
}
