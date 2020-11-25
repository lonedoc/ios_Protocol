//
//  Aliases.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 12/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

public typealias Count = (
    incoming: Int64,
    outgoing: Int64
)

typealias PacketContainer = (
    packet: Packet,
    address: InetAddress
)

typealias PacketContainerExtended = (
    packet: Packet,
    address: InetAddress,
    lastAttemptTime: DispatchTime,
    attemptsCount: Int
)
