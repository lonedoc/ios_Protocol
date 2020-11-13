//
//  OutcomingTransmission.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 26/11/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class OutgoingTransmission {
    private let packetsQueue = Queue<PacketContainer>()
    private var acknowledgements: [Bool]

    let messageNumber: Int64

    let onProgress: ((Int) -> Void)?
    let onComplete: (Bool) -> Void

    init(
        packetsCount: Int,
        messageNumber: Int64,
        progress: ((Int) -> Void)?,
        complete: @escaping (Bool) -> Void
    ) {
        self.messageNumber = messageNumber

        acknowledgements = [Bool](repeating: false, count: packetsCount)

        onProgress = progress
        onComplete = complete
    }

    @Atomic var failed = false

    var progress: Int {
        let acknowledgedPacketsCount = acknowledgements.filter { $0 }.count
        let packetsCount = acknowledgements.count
        return acknowledgedPacketsCount * 100 / packetsCount
    }

    var done: Bool {
        return acknowledgements.allSatisfy { $0 }
    }

    func add(packet: PacketContainer) {
        packetsQueue.enqueue(packet)
    }

    func getNextPacket() -> PacketContainer? {
        return packetsQueue.dequeue()
    }

    func addAcknowledgement(packetNumber: Int) {
        acknowledgements[packetNumber - 1] = true
    }
}
