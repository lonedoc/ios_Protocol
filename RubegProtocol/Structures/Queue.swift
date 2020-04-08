//
//  Queue.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 30/03/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

private class Node<T> {
    private(set) var value: T
    var next: Node<T>?

    init(value: T, next: Node<T>?) {
        self.value = value
        self.next = next
    }
}

class Queue<T> {
    private var head: Node<T>?
    private var tail: Node<T>?

    private let lock: DispatchQueue = {
        let label = "queue_\(UUID().uuidString)"
        return DispatchQueue(label: label, qos: .default, attributes: .concurrent)
    }()

    func enqueue(_ item: T) {
        let node = Node(value: item, next: nil)

        lock.sync(flags: .barrier) {
            if self.head == nil {
                self.head = node
                self.tail  = node
            } else {
                self.tail?.next = node
                self.tail = node
            }
        }
    }

    func dequeue() -> T? {
        let item = head?.value

        lock.sync(flags: .barrier) {
            head = head?.next
            if head == nil {
                tail = nil
            }
        }

        return item
    }

    func removeAll(where predicate: @escaping (T) -> Bool) {
        lock.sync(flags: .barrier) {
            var prev: Node<T>?
            var node = self.head

            while node != nil {
                if predicate(node!.value) {
                    if node === self.head {
                        self.head = node!.next
                    }

                    prev?.next = node!.next

                    if node === self.tail {
                        self.tail = prev
                    }
                } else {
                    prev = node
                }

                node = node!.next
            }
        }
    }

    func clear() {
        lock.sync(flags: .barrier) {
            self.head = nil
            self.tail = nil
        }
    }
}
