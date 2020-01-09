//
//  ByteBuffer.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 12/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class ByteBuffer {
    private var buffer: [Byte]
    private var pointer: Int

    init(buffer: [Byte]) {
        self.buffer = buffer
        pointer = 0
    }

    init(size: Int) {
        buffer = [Byte](repeating: 0, count: size)
        pointer = 0
    }

    var size: Int {
        return buffer.count
    }

    var array: [Byte] {
        return buffer
    }

    func setPosition(_ value: Int) {
        pointer = value
    }

    func clear() {
        buffer = [Byte](repeating: 0, count: buffer.count)
    }

    func put(byte: Byte) {
        buffer[pointer] = byte
        pointer += 1
    }

    func put(byteArray: [Byte]) {
        for byte in byteArray {
            put(byte: byte)
        }
    }

    func put(int32: Int32) {
        let bytes = [Byte](from: int32)
        put(byteArray: bytes)
    }

    func put(int64: Int64) {
        let bytes = [Byte](from: int64)
        put(byteArray: bytes)
    }

    func put(uint32: UInt32) {
        let bytes = [Byte](from: uint32)
        put(byteArray: bytes)
    }

    func put(uint64: UInt64) {
        let bytes = [Byte](from: uint64)
        put(byteArray: bytes)
    }

    func getByte(position: Int) -> Byte {
        return buffer[position]
    }

    func getInt32(position: Int) -> Int32 {
        let bytes = Array(buffer[position...(position + 3)])
        return (try? Int32(bytes: bytes)) ?? 0
    }

    func getInt64(position: Int) -> Int64 {
        let bytes = Array(buffer[position...(position + 7)])
        return (try? Int64(bytes: bytes)) ?? 0
    }

    func getUInt32(position: Int) -> UInt32 {
        let bytes = Array(buffer[position...(position + 3)])
        return (try? UInt32(bytes: bytes)) ?? 0
    }

    func getUInt64(position: Int) -> UInt64 {
        let bytes = Array(buffer[position...(position + 7)])
        return (try? UInt64(bytes: bytes)) ?? 0
    }
}
