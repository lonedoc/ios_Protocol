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
    private var lowPriorityItems = [T]()
    private var mediumPriorityItems = [T]()
    private var highPriorityItems = [T]()

    private let lockQueue = DispatchQueue(label: "rubeg_protocol.priority_queue", qos: .default, attributes: .concurrent)

    var count: Int {
        return self.lowPriorityItems.count + mediumPriorityItems.count + highPriorityItems.count
    }

    func enqueue(_ item: T, priority: Priority) {
        switch priority {
        case .low:
            self.lowPriorityItems.append(item)
        case .medium:
            self.mediumPriorityItems.append(item)
        case .high:
            self.highPriorityItems.append(item)
        }
    }

    func enqueue(_ item: T) {
        enqueue(item, priority: .low)
    }

    func dequeue() -> T? {
        var result: T?

        if highPriorityItems.count > 0 {
            result = highPriorityItems.remove(at: 0)
        } else if mediumPriorityItems.count > 0 {
            result = mediumPriorityItems.remove(at: 0)
        } else if lowPriorityItems.count > 0 {
            result = lowPriorityItems.remove(at: 0)
        } else {
            result = nil
        }

        return result
    }

    func removeAll(where predicate: (T) -> Bool) {
        self.lowPriorityItems.removeAll { predicate($0) }
        self.mediumPriorityItems.removeAll { predicate($0) }
        self.highPriorityItems.removeAll { predicate($0) }
    }

    func clear() {
        self.lowPriorityItems.removeAll()
        self.mediumPriorityItems.removeAll()
        self.highPriorityItems.removeAll()
    }

//    var count: Int {
//        return lockQueue.sync {
//            self.lowPriorityItems.count + mediumPriorityItems.count + highPriorityItems.count
//        }
//    }
//
//    func enqueue(_ item: T, priority: Priority) {
//        lockQueue.sync(flags: .barrier) {
//            switch priority {
//            case .low:
//                self.lowPriorityItems.append(item)
//            case .medium:
//                self.mediumPriorityItems.append(item)
//            case .high:
//                self.highPriorityItems.append(item)
//            }
//        }
//    }
//
//    func enqueue(_ item: T) {
//        enqueue(item, priority: .low)
//    }
//
//    func dequeue() -> T? {
//        var result: T?
//
//        lockQueue.sync(flags: .barrier) {
//            if highPriorityItems.count > 0 {
//                result = highPriorityItems.remove(at: 0)
//            } else if mediumPriorityItems.count > 0 {
//                result = mediumPriorityItems.remove(at: 0)
//            } else if lowPriorityItems.count > 0 {
//                result = lowPriorityItems.remove(at: 0)
//            } else {
//                result = nil
//            }
//        }
//
//        return result
//    }
//
//    func removeAll(where predicate: (T) -> Bool) {
//        lockQueue.sync(flags: .barrier) {
//            self.lowPriorityItems.removeAll { predicate($0) }
//            self.mediumPriorityItems.removeAll { predicate($0) }
//            self.highPriorityItems.removeAll { predicate($0) }
//        }
//    }
//
//    func clear() {
//        lockQueue.sync(flags: .barrier) {
//            self.lowPriorityItems.removeAll()
//            self.mediumPriorityItems.removeAll()
//            self.highPriorityItems.removeAll()
//        }
//    }
}
