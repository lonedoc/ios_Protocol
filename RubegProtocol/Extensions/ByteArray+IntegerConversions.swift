//
//  ByteArray+IntegerConversions.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 13/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

extension Array where Element == Byte {
    init(from number: UInt16) {
        var bytes = [Byte](repeating: 0, count: 2)

        for index in 0...1 {
            let shift = (1 - index) * 8

            bytes[1 - index] = Byte(number >> shift & UInt16(Byte.max))
        }

        self.init(bytes)
    }

    init(from number: UInt32) {
        var bytes = [Byte](repeating: 0, count: 4)

        for index in 0...3 {
            let shift = (3 - index) * 8

            bytes[3 - index] = Byte(number >> shift & UInt32(Byte.max))
        }

        self.init(bytes)
    }

    init(from number: UInt64) {
        var bytes = [Byte](repeating: 0, count: 8)

        for index in 0...7 {
            let shift = (7 - index) * 8

            bytes[7 - index] = Byte(number >> shift & UInt64(Byte.max))
        }

        self.init(bytes)
    }

    init(from number: Int16) {
        var bytes = [Byte](repeating: 0, count: 2)

        for index in 0...1 {
            let shift = (1 - index) * 8

            bytes[1 - index] = Byte(number >> shift & Int16(Byte.max))
        }

        self.init(bytes)
    }

    init(from number: Int32) {
        var bytes = [Byte](repeating: 0, count: 4)

        for index in 0...3 {
            let shift = (3 - index) * 8

            bytes[3 - index] = Byte(number >> shift & Int32(Byte.max))
        }

        self.init(bytes)
    }

    init(from number: Int64) {
        var bytes = [Byte](repeating: 0, count: 8)

        for index in 0...7 {
            let shift = (7 - index) * 8

            bytes[7 - index] = Byte(number >> shift & Int64(Byte.max))
        }

        self.init(bytes)
    }
}
