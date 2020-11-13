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

typealias PacketContainerExtended = (
    packet: Packet,
    host: Host,
    lastAttemptTime: DispatchTime,
    attemptsCount: Int
)
