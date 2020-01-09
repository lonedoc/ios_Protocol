//
//  UnsignedInteger+ByteArrayConversion.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 13/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

extension UnsignedInteger {
    init(bytes: [Byte]) throws {
        if bytes.count != MemoryLayout<Self>.size {
            throw ConversionError.wrongAmountOfBytes
        }

        let value: UInt64 = bytes.reversed().reduce(0) { (accumulator, byte) in
            return accumulator << 8 | UInt64(byte)
        }

        self.init(value)
    }
}
