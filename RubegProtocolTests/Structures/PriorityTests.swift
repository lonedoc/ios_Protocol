//
//  PriorityTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 20/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

// swiftlint:disable function_body_length
class PriorityTests: XCTestCase {
    func testThatComparisonOperatorsWorksCorrectly() {
        XCTAssertTrue(Priority.low == Priority.low)
        XCTAssertFalse(Priority.low == Priority.medium)
        XCTAssertFalse(Priority.low == Priority.high)
        XCTAssertFalse(Priority.low < Priority.low)
        XCTAssertTrue(Priority.low < Priority.medium)
        XCTAssertTrue(Priority.low < Priority.high)
        XCTAssertFalse(Priority.low > Priority.low)
        XCTAssertFalse(Priority.low > Priority.medium)
        XCTAssertFalse(Priority.low > Priority.high)
        XCTAssertTrue(Priority.low <= Priority.low)
        XCTAssertTrue(Priority.low <= Priority.medium)
        XCTAssertTrue(Priority.low <= Priority.high)
        XCTAssertTrue(Priority.low >= Priority.low)
        XCTAssertFalse(Priority.low >= Priority.medium)
        XCTAssertFalse(Priority.low >= Priority.high)

        XCTAssertFalse(Priority.medium == Priority.low)
        XCTAssertTrue(Priority.medium == Priority.medium)
        XCTAssertFalse(Priority.medium == Priority.high)
        XCTAssertFalse(Priority.medium < Priority.low)
        XCTAssertFalse(Priority.medium < Priority.medium)
        XCTAssertTrue(Priority.medium < Priority.high)
        XCTAssertTrue(Priority.medium > Priority.low)
        XCTAssertFalse(Priority.medium > Priority.medium)
        XCTAssertFalse(Priority.medium > Priority.high)
        XCTAssertFalse(Priority.medium <= Priority.low)
        XCTAssertTrue(Priority.medium <= Priority.medium)
        XCTAssertTrue(Priority.medium <= Priority.high)
        XCTAssertTrue(Priority.medium >= Priority.low)
        XCTAssertTrue(Priority.medium >= Priority.medium)
        XCTAssertFalse(Priority.medium >= Priority.high)

        XCTAssertFalse(Priority.high == Priority.low)
        XCTAssertFalse(Priority.high == Priority.medium)
        XCTAssertTrue(Priority.high == Priority.high)
        XCTAssertFalse(Priority.high < Priority.low)
        XCTAssertFalse(Priority.high < Priority.medium)
        XCTAssertFalse(Priority.high < Priority.high)
        XCTAssertTrue(Priority.high > Priority.low)
        XCTAssertTrue(Priority.high > Priority.medium)
        XCTAssertFalse(Priority.high > Priority.high)
        XCTAssertFalse(Priority.high <= Priority.low)
        XCTAssertFalse(Priority.high <= Priority.medium)
        XCTAssertTrue(Priority.high <= Priority.high)
        XCTAssertTrue(Priority.high >= Priority.low)
        XCTAssertTrue(Priority.high >= Priority.medium)
        XCTAssertTrue(Priority.high >= Priority.high)
    }
}
