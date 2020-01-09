//
//  Int64+ByteArrayConversionTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 13/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class ByteArrayToInt64ConversionTests: XCTestCase {
    func testThatErrorIsThrownWhenAmountOfBytesIsWrong() {
        let initInt64WithRightBytes = { try Int64(bytes: [Byte](repeating: 0x00, count: 8)) }
        let initInt64WithTooFewBytes = { try Int64(bytes: [0x00]) }
        let initInt64WithTooManyBytes = { try Int64(bytes: [Byte](repeating: 0x00, count: 10)) }

        XCTAssertNoThrow(try initInt64WithRightBytes())

        XCTAssertThrowsError(try initInt64WithTooFewBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertThrowsError(try initInt64WithTooManyBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }
    }

    func testThatByteArrayConvertsToInt64() {
        var source: [Byte]
        var number: Int64

        source = [0x9F, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        number = (try? Int64(bytes: source)) ?? 0

        XCTAssertEqual(number, 927)

        source = [0x93, 0xCB, 0x3A, 0xCB, 0x02, 0x00, 0x00, 0x00]
        number = (try? Int64(bytes: source)) ?? 0

        XCTAssertEqual(number, 11_999_562_643)

        source = [0x46, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        number = (try? Int64(bytes: source)) ?? 0

        XCTAssertEqual(number, -442)

        source = [0x52, 0x9B, 0xE7, 0xF9, 0xF7, 0xFF, 0xFF, 0xFF]
        number = (try? Int64(bytes: source)) ?? 0

        XCTAssertEqual(number, -34_462_000_302)
    }
}
