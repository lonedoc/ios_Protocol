//
//  Aliases.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 12/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

public typealias Host = (
    address: String,
    port: Int32
)

typealias PacketContainer = (
    packet: Packet,
    host: Host
)

typealias ExtendedPacketContainer = (
    packet: Packet,
    host: Host,
    lastAttemptTime: DispatchTime,
    attemptsCount: Int
)

typealias CallbackContainer<T> = (
    deadline: DispatchTime,
    callback: (T) -> Void
)

struct MessageSignature: Hashable {
    var number: Int64
    var address: String

    init(_ number: Int64, _ address: String) {
        self.number = number
        self.address = address
    }
}
