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
    private var lowPriorityItems = LinkedList<T>()
    private var mediumPriorityItems = LinkedList<T>()
    private var highPriorityItems = LinkedList<T>()

    private let lockQueue = DispatchQueue(
        label: "rubeg_protocol.priority_queue",
        qos: .default,
        attributes: .concurrent
    )

    var count: Int {
        return lockQueue.sync(flags: .barrier) {
            self.lowPriorityItems.count + mediumPriorityItems.count + highPriorityItems.count
        }
    }

    func enqueue(_ item: T, priority: Priority) {
        lockQueue.sync(flags: .barrier) {
            switch priority {
            case .low:
                self.lowPriorityItems.add(item)
            case .medium:
                self.mediumPriorityItems.add(item)
            case .high:
                self.highPriorityItems.add(item)
            }
        }
    }

    func enqueue(_ item: T) {
        enqueue(item, priority: .low)
    }

    func dequeue() -> T? {
        return lockQueue.sync(flags: .barrier) {
            highPriorityItems.removeFirst() ?? mediumPriorityItems.removeFirst() ?? lowPriorityItems.removeFirst()
        }
    }

    func removeAll(where predicate: (T) -> Bool) {
        lockQueue.sync(flags: .barrier) {
            self.lowPriorityItems.removeAll { predicate($0) }
            self.mediumPriorityItems.removeAll { predicate($0) }
            self.highPriorityItems.removeAll { predicate($0) }
        }
    }

    func clear() {
        lockQueue.sync(flags: .barrier) {
            self.lowPriorityItems.clear()
            self.mediumPriorityItems.clear()
            self.highPriorityItems.clear()
        }
    }
}
