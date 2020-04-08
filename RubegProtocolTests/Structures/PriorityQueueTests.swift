//
//  PriorityQueue.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 20/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class PriorityQueueTests: XCTestCase {
    func testThatItemsAreAddedToTheQueue() {
        let queue = PriorityQueue<Int>()

        queue.enqueue(0, priority: .medium)
        queue.enqueue(1, priority: .medium)
        queue.enqueue(2, priority: .medium)

        XCTAssertEqual(queue.dequeue(), 0)
        XCTAssertEqual(queue.dequeue(), 1)
        XCTAssertEqual(queue.dequeue(), 2)
    }

    func testThatHighPriorityItemsAreRetrievedFirst() {
        let queue = PriorityQueue<Int>()
        queue.enqueue(0, priority: .low)
        queue.enqueue(1, priority: .high)
        queue.enqueue(2, priority: .high)
        queue.enqueue(3, priority: .medium)
        queue.enqueue(4, priority: .low)
        queue.enqueue(5, priority: .high)
        queue.enqueue(6, priority: .medium)

        XCTAssertEqual(queue.dequeue(), 1)
        XCTAssertEqual(queue.dequeue(), 2)
        XCTAssertEqual(queue.dequeue(), 5)
        XCTAssertEqual(queue.dequeue(), 3)
        XCTAssertEqual(queue.dequeue(), 6)
        XCTAssertEqual(queue.dequeue(), 0)
        XCTAssertEqual(queue.dequeue(), 4)
    }
}
