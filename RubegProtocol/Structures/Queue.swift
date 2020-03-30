//
//  Queue.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 30/03/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class Queue<T> {
    private var items = LinkedList<T>()

    private let lockQueue = DispatchQueue(label: "rubeg_protocol.queue", qos: .default, attributes: .concurrent)

    var count: Int {
        return lockQueue.sync(flags: .barrier) {
            self.items.count
        }
    }

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
}
