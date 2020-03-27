//
//  LinkedListTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 27/03/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class LinkedListTests: XCTestCase {
    func testThatItemsAreAddedToTheLinkedList() {
        let list = LinkedList<Int>()
        XCTAssertEqual(list.count, 0)
        XCTAssertEqual(list.removeFirst(), nil)

        list.add(0)
        XCTAssertEqual(list.count, 1)

        list.add(1)
        XCTAssertEqual(list.count, 2)

        list.add(2)
        XCTAssertEqual(list.count, 3)

        XCTAssertEqual(list.removeFirst(), 0)
        XCTAssertEqual(list.count, 2)

        XCTAssertEqual(list.removeFirst(), 1)
        XCTAssertEqual(list.count, 1)

        XCTAssertEqual(list.removeFirst(), 2)
        XCTAssertEqual(list.count, 0)

        XCTAssertEqual(list.removeFirst(), nil)
        XCTAssertEqual(list.count, 0)
    }

    func testThatItemsAreRemovedByPredicate() {
        let list = LinkedList<Int>()
        list.add(0)
        list.add(1)
        list.add(2)
        list.add(3)
        list.add(4)
        list.add(5)
        list.add(6)

        XCTAssertEqual(list.count, 7)

        list.removeAll { $0 % 2 != 0 }
        XCTAssertEqual(list.count, 4)

        XCTAssertEqual(list.removeFirst(), 0)
        XCTAssertEqual(list.removeFirst(), 2)
        XCTAssertEqual(list.removeFirst(), 4)
        XCTAssertEqual(list.removeFirst(), 6)
        XCTAssertEqual(list.removeFirst(), nil)
        XCTAssertEqual(list.count, 0)
    }

    func testThatLinkedListErasedByCallingClear() {
        let list = LinkedList<Int>()
        list.add(0)
        list.add(1)
        list.add(2)
        list.add(3)
        list.add(4)
        list.add(5)
        list.add(6)

        XCTAssertEqual(list.count, 7)

        list.clear()
        XCTAssertEqual(list.count, 0)
    }
}
