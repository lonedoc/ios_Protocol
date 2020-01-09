//
//  Int32+ByteArrayConversionTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 12/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class ByteArrayToInt32ConversionTests: XCTestCase {
    func testThatErrorIsThrownWhenAmountOfBytesIsWrong() {
        let initInt32WithRightBytes = { try Int32(bytes: [Byte](repeating: 0x00, count: 4)) }
        let initInt32WithTooFewBytes = { try Int32(bytes: [0x00]) }
        let initInt32WithTooManyBytes = { try Int32(bytes: [Byte](repeating: 0x00, count: 10)) }

        XCTAssertNoThrow(try initInt32WithRightBytes())

        XCTAssertThrowsError(try initInt32WithTooFewBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertThrowsError(try initInt32WithTooManyBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }
    }

    func testThatByteArrayConvertsToInt32() {
        var source: [Byte]
        var number: Int32

        source = [0xE8, 0x02, 0x00, 0x00]
        number = (try? Int32(bytes: source)) ?? 0

        XCTAssertEqual(number, 744)

        source = [0x25, 0x61, 0x85, 0x74]
        number = (try? Int32(bytes: source)) ?? 0

        XCTAssertEqual(number, 1_954_898_213)

        source = [0xFF, 0xFE, 0xFF, 0xFF]
        number = (try? Int32(bytes: source)) ?? 0

        XCTAssertEqual(number, -257)

        source = [0x6F, 0xBC, 0x7B, 0x97]
        number = (try? Int32(bytes: source)) ?? 0

        XCTAssertEqual(number, -1_753_498_513)
    }
}
