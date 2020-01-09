//
//  ByteArray+IntegerConversionsTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 13/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class ByteArrayFromIntegerConversionsTests: XCTestCase {
    func testThatInt16ConvertsToByteArray() {
        var source: Int16
        var bytes: [Byte]

        source = 2_599
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x27, 0x0A])

        source = 12_497
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0xD1, 0x30])

        source = -231
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x19, 0xFF])

        source = -11_465
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x37, 0xD3])
    }

    func testThatInt32ConvertsToByteArray() {
        var source: Int32
        var bytes: [Byte]

        source = 19_375_421
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x3D, 0xA5, 0x27, 0x01])

        source = 293
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x25, 0x01, 0x00, 0x00])

        source = -347_576_873
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0xD7, 0x65, 0x48, 0xEB])

        source = -322
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0xBE, 0xFE, 0xFF, 0xFF])
    }

    func testThatInt64ConvertsToByteArray() {
        var source: Int64
        var bytes: [Byte]

        source = 927
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x9F, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

        source = 11_999_562_643
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x93, 0xCB, 0x3A, 0xCB, 0x02, 0x00, 0x00, 0x00])

        source = -442
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x46, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])

        source = -34_462_000_302
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x52, 0x9B, 0xE7, 0xF9, 0xF7, 0xFF, 0xFF, 0xFF])
    }

    func testThatUInt16ConvertsToByteArray() {
        var source: UInt16
        var bytes: [Byte]

        source = 257
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0x01, 0x01])

        source = 63_247
        bytes = [Byte](from: source)
        XCTAssertEqual(bytes, [0x0F, 0xF7])
    }

    func testThatUInt32ConvertsToByteArray() {
        var source: UInt32
        var bytes: [Byte]

        source = 744
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0xE8, 0x02, 0x00, 0x00])

        source = 1_954_898_213
        bytes = [Byte](from: source)
        XCTAssertEqual(bytes, [0x25, 0x61, 0x85, 0x74])
    }

    func testThatUInt64ConvertsToByteArray() {
        var source: UInt64
        var bytes: [Byte]

        source = 219
        bytes = [Byte](from: source)

        XCTAssertEqual(bytes, [0xDB, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

        source = 2_152_956_778_199_721_472
        bytes = [Byte](from: source)
        XCTAssertEqual(bytes, [0x00, 0x26, 0x5D, 0x6D, 0xC8, 0xD6, 0xE0, 0x1D])
    }
}
