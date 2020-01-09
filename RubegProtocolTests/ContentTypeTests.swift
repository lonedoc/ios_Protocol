//
//  ContentTypeTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 17/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class ContentTypeTests: XCTestCase {
    func testThatContentTypeConvertsToByteCorrectly() {
        XCTAssertEqual(ContentType.acknowledgement.rawValue, 0xFF)
        XCTAssertEqual(ContentType.sync.rawValue, 0xFE)
        XCTAssertEqual(ContentType.error.rawValue, 0xFD)
        XCTAssertEqual(ContentType.string.rawValue, 0x00)
        XCTAssertEqual(ContentType.binary.rawValue, 0x01)
    }

    func testThatByteConvertsToContentTypeCorrectly() {
        XCTAssertEqual(ContentType(rawValue: 0xFF), .acknowledgement)
        XCTAssertEqual(ContentType(rawValue: 0xFE), .sync)
        XCTAssertEqual(ContentType(rawValue: 0xFD), .error)
        XCTAssertEqual(ContentType(rawValue: 0x00), .string)
        XCTAssertEqual(ContentType(rawValue: 0x01), .binary)
    }
}
