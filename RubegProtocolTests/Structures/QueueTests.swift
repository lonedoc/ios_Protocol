//
//  QueueTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 08/04/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class QueueTests: XCTestCase {
    func testThatItemsAreAddedAndRemovedCorrectly() {
        let queue = Queue<Int>()

        queue.enqueue(0)
        queue.enqueue(1)
        queue.enqueue(2)

        XCTAssertEqual(queue.dequeue(), 0)
        XCTAssertEqual(queue.dequeue(), 1)
        XCTAssertEqual(queue.dequeue(), 2)
    }

    func testThatItemsAreRemovedByPredicateCorrectrly() {
        let queue = Queue<Int>()

        queue.enqueue(0)
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        queue.enqueue(4)
        queue.enqueue(5)
        queue.enqueue(6)
        queue.enqueue(7)
        queue.enqueue(8)
        queue.enqueue(9)
        queue.enqueue(10)

        queue.removeAll { $0 % 2 == 0 }

        XCTAssertEqual(queue.dequeue(), 1)
        XCTAssertEqual(queue.dequeue(), 3)
        XCTAssertEqual(queue.dequeue(), 5)
        XCTAssertEqual(queue.dequeue(), 7)
        XCTAssertEqual(queue.dequeue(), 9)
        XCTAssertEqual(queue.dequeue(), nil)

//        for number in 0...10 {
//            queue.enqueue(number)
//        }
//
//        queue.removeAll { $0 % 2 == 0 }
//
//        for number in 0...10 {
//            if number % 2 == 0 {
//                continue
//            }
//
//            XCTAssertEqual(queue.dequeue(), number)
//        }
//
//        XCTAssertEqual(queue.dequeue(), nil)
    }
//    func testThatItemsAreAddedToTheQueue() {
//        let queue = PriorityQueue<Int>()
//
//        queue.enqueue(0, priority: .medium)
//        queue.enqueue(1, priority: .medium)
//        queue.enqueue(2, priority: .medium)
//
//        XCTAssertEqual(queue.dequeue(), 0)
//        XCTAssertEqual(queue.dequeue(), 1)
//        XCTAssertEqual(queue.dequeue(), 2)
//    }
//
//    func testThatHighPriorityItemsAreRetrievedFirst() {
//        let queue = PriorityQueue<Int>()
//        queue.enqueue(0, priority: .low)
//        queue.enqueue(1, priority: .high)
//        queue.enqueue(2, priority: .high)
//        queue.enqueue(3, priority: .medium)
//        queue.enqueue(4, priority: .low)
//        queue.enqueue(5, priority: .high)
//        queue.enqueue(6, priority: .medium)
//
//        XCTAssertEqual(queue.dequeue(), 1)
//        XCTAssertEqual(queue.dequeue(), 2)
//        XCTAssertEqual(queue.dequeue(), 5)
//        XCTAssertEqual(queue.dequeue(), 3)
//        XCTAssertEqual(queue.dequeue(), 6)
//        XCTAssertEqual(queue.dequeue(), 0)
//        XCTAssertEqual(queue.dequeue(), 4)
//    }
}
