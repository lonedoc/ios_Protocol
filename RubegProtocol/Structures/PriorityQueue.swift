//
//  Queue.swift
//  RUDPshowcase
//
//  Created by Rubeg NPO on 15/05/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

// Disable SwiftLint rules
// swiftlint:disable line_length

import Foundation

class PriorityQueue<T> {
    private var items = [(data: T, priority: Priority)]()
    private let lockQueue = DispatchQueue(label: "rubeg_protocol.priority_queue", qos: .default, attributes: .concurrent)

    var count: Int {
        return lockQueue.sync {
            self.items.count
        }
    }

    func enqueue(_ item: T, priority: Priority) {
        lockQueue.sync(flags: .barrier) {
            for index in 0..<self.items.count where priority > self.items[index].priority {
                self.items.insert((item, priority), at: index)
                return
            }

            self.items.append((item, priority))
        }
    }

    func enqueue(_ item: T) {
        enqueue(item, priority: .low)
    }

    func dequeue() -> T? {
        return lockQueue.sync(flags: .barrier) {
            self.items.count == 0 ? nil : self.items.remove(at: 0).data
        }
    }

    func removeAll(where predicate: (T) -> Bool) {
        lockQueue.sync(flags: .barrier) {
            self.items.removeAll { predicate($0.data) }
        }
    }

    func clear() {
        lockQueue.sync(flags: .barrier) {
            self.items.removeAll()
        }
    }
}
