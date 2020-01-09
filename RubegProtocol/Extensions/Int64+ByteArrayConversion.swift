//
//  Int64+ByteArrayConversion.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 13/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

extension Int64 {
    init(bytes: [Byte]) throws {
        if bytes.count != MemoryLayout<Self>.size {
            throw ConversionError.wrongAmountOfBytes
        }

        let data = Data(bytes)

        self.init(littleEndian: data.withUnsafeBytes { $0.load(as: Int64.self) })
    }
}
