//
// Created by Rubeg NPO on 03/12/2019.
// Copyright (c) 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class IncomingTransmission {
    private var packets: [Bool]
    private var _data: ByteBuffer
    private var deadline: DispatchTime

    init(packet: Packet) {
        packets = [Bool](repeating: false, count: Int(packet.headers.packetsCount))
        _data = ByteBuffer(size: Int(packet.headers.messageSize))

        deadline = .now() + .seconds(ProtocolConstants.messageDropInterval)

        add(packet: packet)
    }

    var done: Bool {
        return packets.allSatisfy { $0 }
    }

    var failed: Bool {
        return deadline < .now()
    }

    var data: [Byte]? {
        return done ? _data.array : nil
    }

    func add(packet: Packet) {
        guard packet.headers.packetNumber <= packets.count else {
            return
        }

        guard !packets[Int(packet.headers.packetNumber) - 1] else {
            return
        }

        guard let packetData = packet.data else {
            return
        }

        guard Int(packet.headers.shift) + packetData.count <= _data.size else {
            return
        }

        _data.setPosition(Int(packet.headers.shift))
        _data.put(byteArray: packetData)

        packets[Int(packet.headers.packetNumber) - 1] = true

        deadline = .now() + .seconds(ProtocolConstants.messageDropInterval)
    }
}
