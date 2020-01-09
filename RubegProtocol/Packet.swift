//
//  Packet.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 18/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class Packet {
    private(set) var headers: Headers
    private(set) var data: [Byte]?

    static func createAcknowledgement(for packet: Packet) -> Packet {
        let headers = HeadersBuilder()
            .set(messageNumber: packet.headers.messageNumber)
            .set(messageSize: packet.headers.messageSize)
            .set(packetsCount: packet.headers.packetsCount)
            .set(packetNumber: packet.headers.packetNumber)
            .set(packetSize: packet.headers.packetSize)
            .set(shift: packet.headers.shift)
            .set(firstSize: packet.headers.firstSize)
            .set(secondSize: packet.headers.secondSize)
            .set(token: packet.headers.token)
            .build(contentType: .acknowledgement)

        return Packet(headers: headers)
    }

    init(data: [Byte]? = nil, headers: Headers) {
        self.headers = headers
        self.data = data
    }

    // TODO: replace with factory method that returns optional packet
    init(encoded: Data) {
        let bytes: [Byte] = Array(encoded)

        let (headers, body) = Coder().decode(data: bytes)

        self.headers = headers
        self.data = body
    }

    func encode() -> Data {
        let bytes = Coder().encode(data: data, headers: headers)
        return Data(bytes)
    }

    func isAcknowledgementOf(_ packet: Packet) -> Bool {
        guard headers.contentType == .acknowledgement else {
            return false
        }

        let sameMessageNumber = headers.messageNumber == packet.headers.messageNumber
        let samePacketsCount = headers.packetsCount == packet.headers.packetsCount
        let samePacketNumber = headers.packetNumber == packet.headers.packetNumber

        return sameMessageNumber && samePacketsCount && samePacketNumber
    }
}

extension Packet: CustomStringConvertible {
    var description: String {
        return "{ content type: \(headers.contentType), " +
            "message number: \(headers.messageNumber), " +
            "packet number: \(headers.packetNumber), " +
            "packets count: \(headers.packetsCount) }"
    }
}
