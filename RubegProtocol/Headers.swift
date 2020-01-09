//
//  Headers.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 17/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class Headers {
    var contentType: ContentType
    var messageNumber: Int64
    var messageSize: Int32
    var packetsCount: Int32
    var packetNumber: Int32
    var packetSize: Int32
    var shift: Int32
    var firstSize: Int32
    var secondSize: Int32
    var token: String?

    init(
        contentType: ContentType,
        messageNumber: Int64,
        messageSize: Int32,
        packetsCount: Int32,
        packetNumber: Int32,
        packetSize: Int32,
        shift: Int32,
        firstSize: Int32,
        secondSize: Int32,
        token: String?
    ) {
        self.contentType = contentType
        self.messageNumber = messageNumber
        self.messageSize = messageSize
        self.packetsCount = packetsCount
        self.packetNumber = packetNumber
        self.packetSize = packetSize
        self.shift = shift
        self.firstSize = firstSize
        self.secondSize = secondSize
        self.token = token
    }
}
