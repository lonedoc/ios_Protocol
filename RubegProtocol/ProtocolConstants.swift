//
//  ProtocolConstants.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 27.10.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class ProtocolConstants {
    static let packetSize = 960
    static let messageDropInterval = 30_000
    static let congestionWindowSize = 64
    static let retransmitInterval = 3_000
    static let maxAttemptCount = 6
    static let sleepInterval: UInt32 = 100
}
