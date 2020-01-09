//
//  Int16+ByteArrayConversionTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 13/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class ByteArrayToInt16ConversionTests: XCTestCase {
    func testThatErrorIsThrownWhenAmountOfBytesIsWrong() {
        let initInt16WithRightBytes = { try Int16(bytes: [Byte](repeating: 0x00, count: 2)) }
        let initInt16WithTooFewBytes = { try Int16(bytes: [0x00]) }
        let initInt16WithTooManyBytes = { try Int16(bytes: [Byte](repeating: 0x00, count: 10)) }

        XCTAssertNoThrow(try initInt16WithRightBytes())

        XCTAssertThrowsError(try initInt16WithTooFewBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertThrowsError(try initInt16WithTooManyBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }
    }

    func testThatByteArrayConvertsToInt16() {
        var source: [Byte]
        var number: Int16

        source = [0x27, 0x0A]
        number = (try? Int16(bytes: source)) ?? 0

        XCTAssertEqual(number, 2_599)

        source = [0xD1, 0x30]
        number = (try? Int16(bytes: source)) ?? 0

        XCTAssertEqual(number, 12_497)

        source = [0x19, 0xFF]
        number = (try? Int16(bytes: source)) ?? 0

        XCTAssertEqual(number, -231)

        source = [0x37, 0xD3]
        number = (try? Int16(bytes: source)) ?? 0

        XCTAssertEqual(number, -11_465)
    }
}
