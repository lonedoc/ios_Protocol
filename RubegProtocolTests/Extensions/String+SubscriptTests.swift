//
//  String+SubscriptTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 17/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class StringSubscriptTests: XCTestCase {
    func testThatSubscriptWithIndexReturnsCorrectCharacter() {
        let source = "Hello, World!"

        XCTAssertEqual(source[7], "W")
    }

    func testThatSubscriptWithRangesReturnsCorrectSubstring() {
        let source = "Hello, World!"

        XCTAssertEqual(source[7...11], "World")
        XCTAssertEqual(source[7..<12], "World")
        XCTAssertEqual(source[...4], "Hello")
        XCTAssertEqual(source[..<5], "Hello")
        XCTAssertEqual(source[7...], "World!")
    }
}
