//
//  UnsignedInteger+ByteArrayConversionTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 13/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

// Disable SwiftLint rules
// swiftlint:disable type_name

import XCTest
@testable import RubegProtocol

class ByteArrayToUnsignedIntegerConversionTests: XCTestCase {
    func testThatErrorIsThrownWhenAmountOfBytesIsWrong() {
        let initUInt16WithRightBytes = { try UInt16(bytes: [Byte](repeating: 0x00, count: 2)) }
        let initUInt16WithTooFewBytes = { try UInt16(bytes: [0x00]) }
        let initUInt16WithTooManyBytes = { try UInt16(bytes: [Byte](repeating: 0x00, count: 10)) }
        let initUInt32WithRightBytes = { try UInt32(bytes: [Byte](repeating: 0x00, count: 4)) }
        let initUInt32WithTooFewBytes = { try UInt32(bytes: [0x00]) }
        let initUInt32WithTooManyBytes = { try UInt32(bytes: [Byte](repeating: 0x00, count: 10)) }
        let initUInt64WithRightBytes = { try UInt64(bytes: [Byte](repeating: 0x00, count: 8)) }
        let initUInt64WithTooFewBytes = { try UInt16(bytes: [0x00]) }
        let initUInt64WithTooManyBytes = { try UInt16(bytes: [Byte](repeating: 0x00, count: 10)) }

        XCTAssertNoThrow(try initUInt16WithRightBytes())

        XCTAssertThrowsError(try initUInt16WithTooFewBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertThrowsError(try initUInt16WithTooManyBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertNoThrow(try initUInt32WithRightBytes())

        XCTAssertThrowsError(try initUInt32WithTooFewBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertThrowsError(try initUInt32WithTooManyBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertNoThrow(try initUInt64WithRightBytes())

        XCTAssertThrowsError(try initUInt64WithTooFewBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }

        XCTAssertThrowsError(try initUInt64WithTooManyBytes()) { error in
            XCTAssertEqual(error as? ConversionError, ConversionError.wrongAmountOfBytes)
        }
    }

    func testThatByteArrayConvertsToUInt16() {
        var source: [Byte]
        var number: UInt16

        source = [0x01, 0x01]
        number = (try? UInt16(bytes: source)) ?? 0

        XCTAssertEqual(number, 257)

        source = [0x0F, 0xF7]
        number = (try? UInt16(bytes: source)) ?? 0

        XCTAssertEqual(number, 63_247)
    }

    func testThatByteArrayConvertsToUInt32() {
        var source: [Byte]
        var number: UInt32

        source = [0xE8, 0x02, 0x00, 0x00]
        number = (try? UInt32(bytes: source)) ?? 0

        XCTAssertEqual(number, 744)

        source = [0x25, 0x61, 0x85, 0x74]
        number = (try? UInt32(bytes: source)) ?? 0

        XCTAssertEqual(number, 1_954_898_213)
    }

    func testThatByteArrayConvertsToUInt64() {
        var source: [Byte]
        var number: UInt64

        source = [0xDB, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        number = (try? UInt64(bytes: source)) ?? 0

        XCTAssertEqual(number, 219)

        source = [0x00, 0x26, 0x5D, 0x6D, 0xC8, 0xD6, 0xE0, 0x1D]
        number = (try? UInt64(bytes: source)) ?? 0
        print(number)

        XCTAssertEqual(number, 2_152_956_778_199_721_472)
    }
}
