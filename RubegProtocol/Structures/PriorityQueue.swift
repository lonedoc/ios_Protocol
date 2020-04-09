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
    private var lowPriorityItems = Queue<T>()
    private var mediumPriorityItems = Queue<T>()
    private var highPriorityItems = Queue<T>()

    func enqueue(_ item: T, priority: Priority = .low) {
        switch priority {
        case .low:
            lowPriorityItems.enqueue(item)
        case .medium:
            mediumPriorityItems.enqueue(item)
        case .high:
            highPriorityItems.enqueue(item)
        }
    }

    func dequeue() -> T? {
        return highPriorityItems.dequeue() ?? mediumPriorityItems.dequeue() ?? lowPriorityItems.dequeue()
    }

    func removeAll(where predicate: @escaping (T) -> Bool) {
        lowPriorityItems.removeAll(where: predicate)
        mediumPriorityItems.removeAll(where: predicate)
        highPriorityItems.removeAll(where: predicate)
    }

    func clear() {
        lowPriorityItems.clear()
        mediumPriorityItems.clear()
        highPriorityItems.clear()
    }
}
