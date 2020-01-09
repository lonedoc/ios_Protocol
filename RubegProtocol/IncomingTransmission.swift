//
// Created by Rubeg NPO on 03/12/2019.
// Copyright (c) 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class IncomingTransmission {
    let messageDropInterval = 30

    private var packets: [Bool]
    private var data: ByteBuffer

    private var deadline: DispatchTime

    init(packet: Packet) {
        packets = [Bool](repeating: false, count: Int(packet.headers.packetsCount))
        data = ByteBuffer(size: Int(packet.headers.messageSize))

        deadline = .now() + .seconds(30)

        add(packet: packet)
    }

    var done: Bool {
        return packets.allSatisfy { $0 }
    }

    var failed: Bool {
        return deadline < .now()
    }

    var message: [Byte]? {
        return done ? data.array : nil
    }

    func add(packet: Packet) {
        guard packet.headers.shift < data.size else {
            return
        }

        guard packet.headers.packetNumber <= packets.count else {
            return
        }

        guard let packetData = packet.data else {
            return
        }

        data.setPosition(Int(packet.headers.shift))
        data.put(byteArray: packetData)

        packets[Int(packet.headers.packetNumber) - 1] = true

        deadline = .now() + .seconds(30)
    }
}
