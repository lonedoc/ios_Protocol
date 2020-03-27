//
//  LinkedList.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 27/03/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

private class Node<T> {
    private(set) var value: T
    var previous: Node<T>?
    var next: Node<T>?

    init(value: T, previous: Node<T>?, next: Node<T>?) {
        self.value = value
        self.previous = previous
        self.next = next
    }
}

class LinkedList<T> {
    private var head: Node<T>?
    private var tail: Node<T>?
    private(set) var count: Int = 0

    func add(_ item: T) {
        let node = Node(value: item, previous: tail, next: nil)

        if head == nil && tail == nil {
            head = node
        }

        tail?.next = node
        tail = node

        count += 1
    }

    func removeFirst() -> T? {
        if head == nil {
            return nil
        }

        let value = head!.value
        head = head!.next

        if count > 0 {
            count -= 1
        }

        if count == 0 {
            tail = nil
        }

        return value
    }

    func removeAll(where predicate: (T) -> Bool) {
        var node = head

        while node != nil {
            if predicate(node!.value) {
                node!.previous?.next = node!.next
                node!.next?.previous = node!.previous

                if node!.previous == nil {
                    head = node!.next
                }

                if node!.next == nil {
                    tail = node!.previous
                }

                count -= 1
            }

            node = node!.next
        }
    }

    func clear() {
        head = nil
        tail = nil
        count = 0
    }
}
