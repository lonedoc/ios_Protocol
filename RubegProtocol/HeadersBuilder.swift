//
//  HeadersBuilder.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 17/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class HeadersBuilder {
    private var messageNumber: Int64 = 0
    private var messageSize: Int32 = 0
    private var packetsCount: Int32 = 0
    private var packetNumber: Int32 = 0
    private var packetSize: Int32 = 0
    private var shift: Int32 = 0
    private var firstSize: Int32 = 0
    private var secondSize: Int32 = 0
    private var token: String?

    func set(messageNumber: Int64) -> HeadersBuilder {
        self.messageNumber = messageNumber
        return self
    }

    func set(messageSize: Int32) -> HeadersBuilder {
        self.messageSize =  messageSize
        return self
    }

    func set(packetsCount: Int32) -> HeadersBuilder {
        self.packetsCount = packetsCount
        return self
    }

    func set(packetNumber: Int32) -> HeadersBuilder {
        self.packetNumber = packetNumber
        return self
    }

    func set(packetSize: Int32) -> HeadersBuilder {
        self.packetSize = packetSize
        return self
    }

    func set(shift: Int32) -> HeadersBuilder {
        self.shift = shift
        return self
    }

    func set(firstSize: Int32) -> HeadersBuilder {
        self.firstSize = firstSize
        return self
    }

    func set(secondSize: Int32) -> HeadersBuilder {
        self.secondSize = secondSize
        return self
    }

    func set(token: String?) -> HeadersBuilder {
        self.token = token
        return self
    }

    func build(contentType: ContentType) -> Headers {
        return Headers(
            contentType: contentType,
            messageNumber: messageNumber,
            messageSize: messageSize,
            packetsCount: packetsCount,
            packetNumber: packetNumber,
            packetSize: packetSize,
            shift: shift,
            firstSize: firstSize,
            secondSize: secondSize,
            token: token
        )
    }
}
