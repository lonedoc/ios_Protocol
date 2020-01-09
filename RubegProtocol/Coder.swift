//
//  Coder.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 17/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class Coder {
    private let vector: [Byte] = [
        0x50, 0x0D, 0x39, 0x41, 0x3B, 0x89, 0x33, 0x88, 0xD1, 0x45, 0x3C, 0x90, 0x16, 0xC8, 0x0E, 0x9F,
        0x64, 0x3D, 0xA1, 0x80, 0xB3, 0x49, 0x34, 0xCB, 0x4D, 0x8A, 0x09, 0xCE, 0x82, 0x1F, 0x1E, 0xA0,
        0x36, 0x98, 0xE5, 0xC3, 0x69, 0xEC, 0xFD, 0x59, 0xD4, 0x1D, 0xB9, 0xD6, 0xEA, 0x11, 0x65, 0xE1,
        0x4A, 0x9D, 0x51, 0x55, 0x0F, 0x4F, 0x56, 0xF2, 0x95, 0xA2, 0x25, 0x24, 0x53, 0x67, 0xD3, 0xB1,
        0x70, 0xE4, 0xF3, 0x03, 0xC9, 0xA5, 0x47, 0x9C, 0xF7, 0x8D, 0x28, 0x0B, 0x05, 0x07, 0x5D, 0xAA,
        0xAE, 0x32, 0xF0, 0xAD, 0x4C, 0x57, 0x44, 0xF1, 0xEF, 0xF5, 0x93, 0xDB, 0x15, 0xBC, 0x2D, 0xF4,
        0x5E, 0x5F, 0x75, 0xCA, 0x00, 0x6D, 0x66, 0xA4, 0xA9, 0x61, 0x2C, 0x8F, 0x97, 0x26, 0xBB, 0x7D,
        0x85, 0xB4, 0xA7, 0xFB, 0xA8, 0x86, 0x04, 0xE3, 0xD9, 0xF9, 0xDF, 0xC4, 0xE6, 0xB0, 0x35, 0xE9,
        0xC1, 0xBF, 0x54, 0x9E, 0x43, 0x13, 0xC6, 0x8E, 0x84, 0x71, 0xCC, 0xDC, 0x20, 0xB5, 0xFC, 0x0C,
        0x9A, 0x96, 0xEB, 0xB8, 0xBD, 0x60, 0xC5, 0x14, 0xCD, 0x2E, 0x78, 0x83, 0xAF, 0x3A, 0x06, 0xD5,
        0xE7, 0xDD, 0x2B, 0xAC, 0xD2, 0x30, 0x01, 0x21, 0x2A, 0x23, 0xE2, 0x19, 0x92, 0x17, 0x79, 0x5C,
        0xED, 0x3E, 0xA6, 0x46, 0x4E, 0xFE, 0x1B, 0x62, 0x08, 0x4B, 0x6F, 0x38, 0x40, 0x6E, 0xC2, 0xBA,
        0x76, 0x7E, 0xFA, 0x1C, 0x63, 0xB6, 0xBE, 0x1A, 0xC7, 0x6C, 0xDE, 0x74, 0x29, 0xEE, 0x31, 0xF6,
        0x02, 0x77, 0x5B, 0xDA, 0x0A, 0x52, 0x42, 0x81, 0x7F, 0xB2, 0x7C, 0x6B, 0x87, 0x8C, 0xB7, 0x94,
        0x12, 0xCF, 0x5A, 0x6A, 0xD7, 0xE0, 0x48, 0x72, 0x22, 0xFF, 0x27, 0xC0, 0x2F, 0x37, 0x91, 0xD8,
        0x3F, 0x7A, 0xD0, 0x18, 0x73, 0xE8, 0xF8, 0x10, 0x58, 0x7B, 0x8B, 0x99, 0x68, 0x9B, 0xA3, 0xAB
    ]

    private let headersSize = 55

    func encode(data: [Byte]? = nil, headers: Headers) -> [Byte] {
        // CFByteOrderBetCurrent()
        // CFByteOrderLittleEndian
        // CFByteOrderBigEndian

        let tokenBytes: [Byte]

        if let token = headers.token {
            tokenBytes = hexStringToBytes(token)
        } else {
            tokenBytes = []
        }

        let packetSize: Int32

        if let data = data {
            packetSize = Int32(data.count) + 2
        } else {
            packetSize = 0
        }

        // Headers
        let headersBuffer = ByteBuffer(size: headersSize + 2)
        headersBuffer.setPosition(2)
        headersBuffer.put(byte: 0xAA)
        headersBuffer.put(byte: 0xFF)
        headersBuffer.put(byte: headers.contentType.rawValue)
        headersBuffer.put(int32: packetSize)
        headersBuffer.put(int32: 0) // first size
        headersBuffer.put(int32: 0) // second size
        headersBuffer.put(int32: headers.shift) // shift
        headersBuffer.put(int32: headers.messageSize)
        headersBuffer.put(int64: headers.messageNumber)
        headersBuffer.put(int32: headers.packetsCount)
        headersBuffer.put(int32: headers.packetNumber)
        headersBuffer.put(byteArray: tokenBytes)
        insertKeys(headersBuffer)

        var headersArray = headersBuffer.array
        code(&headersArray, vector: vector)

        guard let data = data else {
            return headersArray
        }

        // Data
        let dataBuffer = ByteBuffer(size: Int(packetSize))
        dataBuffer.setPosition(2)
        dataBuffer.put(byteArray: data)
        insertKeys(dataBuffer)

        var dataArray = dataBuffer.array
        code(&dataArray, vector: vector)

        return headersArray + dataArray
    }

    func decode(data: [Byte]) -> (Headers, [Byte]?) {
        var headersArray = [Byte](repeating: 0, count: headersSize + 2)

        for index in 0..<(headersSize + 2) {
            headersArray[index] = data[index]
        }

        code(&headersArray, vector: vector)

        let headersBuffer = ByteBuffer(buffer: headersArray)
        let rawContentType = headersBuffer.getByte(position: 4)
        let contentType = ContentType(rawValue: rawContentType)!
        let packetSize = headersBuffer.getInt32(position: 5)
        let messageSize = headersBuffer.getInt32(position: 21)
        let messageNumber = headersBuffer.getInt64(position: 25)
        let packetsCount = headersBuffer.getInt32(position: 33)
        let packetNumber = headersBuffer.getInt32(position: 37)
        let shift = headersBuffer.getInt32(position: 17)
        let firstSize = headersBuffer.getInt32(position: 9)
        let secondSize = headersBuffer.getInt32(position: 13)

        let headers = Headers(
            contentType: contentType,
            messageNumber: messageNumber,
            messageSize: messageSize,
            packetsCount: packetsCount,
            packetNumber: packetNumber,
            packetSize: packetSize,
            shift: shift,
            firstSize: firstSize,
            secondSize: secondSize,
            token: nil
        )

        var body: [Byte]?

        if contentType != .acknowledgement && packetSize > 0 {
            let size = Int(packetSize)

            body = [Byte](repeating: 0, count: size)

            for index in 0..<size {
                body![index] = data[headersSize + 2 + index]
            }

            code(&body!, vector: vector)

            body!.remove(at: 0)
            body!.remove(at: 0)
        }

        return (headers, body)
    }

    private func hexStringToBytes(_ string: String) -> [Byte] {
        let hex = string
            .filter { $0 != "-" }
            .lowercased()

        var result = [Byte](repeating: 0, count: hex.count / 2)

        for index in stride(from: 0, to: hex.count, by: 2) {
            let substr = hex[index...(index + 1)]

            result[index / 2] = Byte(substr, radix: 16)!
        }

        return result
    }

    private func insertKeys(_ buffer: ByteBuffer) {
        for index in 0...1 {
            let byteA = Byte.random(in: Byte.min...Byte.max)
            let byteB = Byte.random(in: Byte.min...Byte.max)
            let key = byteA ^ byteB

            buffer.setPosition(index)
            buffer.put(byte: key)
        }
    }

    private func code(_ arr: inout [Byte], vector: [Byte]) {
        var right = Int(arr[0]) & 0xFF
        var left = Int(arr[1]) & 0xFF

        for index in 2..<arr.count {
            arr[index] ^= vector[right] ^ vector[left]

            right = right < 0xFF ? right + 1 : 0
            left = left > 0 ? left - 1 : 0xFF
        }
    }
}
