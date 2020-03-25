//
//  Socket.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 12/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation
import Socket

public class RubegSocket {
    private let packetSize = 962
    private let connectionDropInterval = 20_000
    private let syncInterval = 3000
    private let retransmittInterval = 10_000
    private let sleepInterval: UInt32 = 100_000
    private let maxAttemptsCount = 3
    private let congestionWindowSize = 32

    private var outcomingMessagesCount = [String: Int64]()
    private var incomingMessagesCount = [String: Int64]()

    private var outcomingTransmissions = [String: [Int64: OutcomingTransmission]]()
    private var incomingTransmissions = [String: [Int64: IncomingTransmission]]()

    private let packetsQueue = PriorityQueue<PacketContainer>()
    private var congestionWindow = [PacketContainer]()

    private var socket: Socket

    private var started = false

    private let communicationQueue = DispatchQueue(label: "rubeg_protocol.communication_queue", qos: .default)
    private let packetPreparationQueue = DispatchQueue(label: "rubeg_protocol.packet_preparation_queue", qos: .default)

    public weak var delegate: RubegSocketDelegate?

    public init() throws {
        socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
        try socket.setBlocking(mode: false)
    }

    public func open() {
        if started {
            return
        }

        started = true

        communicationQueue.async {
            self.startCommunicationLoop()
        }
    }

    public func close() {
        started = false
    }

    public func send(message: String, token: String?, to host: Host, completion: @escaping (Bool) -> Void) {
        let data: [Byte] = Array(message.utf8)

        packetPreparationQueue.async {
            self.send(
                data: data,
                token: token,
                contentType: .string,
                host: host,
                completion: completion
            )
        }
    }

    public func send(message: [Byte], token: String?, to host: Host, completion: @escaping (Bool) -> Void) {
        packetPreparationQueue.async {
            self.send(
                data: message,
                token: token,
                contentType: .binary,
                host: host,
                completion: completion
            )
        }
    }

    private func send(data: [Byte], token: String?, contentType: ContentType, host: Host, completion: @escaping (Bool) -> Void) {
        if !outcomingMessagesCount.keys.contains(host.address) {
            outcomingMessagesCount[host.address] = 0
        }

        outcomingMessagesCount[host.address]! += 1

        let messageNumber = outcomingMessagesCount[host.address]!

        var packetsCount = data.count / packetSize

        if data.count % packetSize != 0 {
            packetsCount += 1
        }

        if outcomingTransmissions[host.address] == nil {
            outcomingTransmissions[host.address] = [Int64: OutcomingTransmission]()
        }

        outcomingTransmissions[host.address]![messageNumber] =
            OutcomingTransmission(packetsCount, completion: completion)

        var packetNumber: Int32 = 1

        var leftBound = 0
        while leftBound < data.count {
            let rightBound = leftBound + packetSize < data.count ? leftBound + packetSize : data.count

            let chunk = Array(data[leftBound..<rightBound])

            let headers = HeadersBuilder()
                .set(messageNumber: messageNumber)
                .set(messageSize: Int32(data.count))
                .set(packetNumber: packetNumber)
                .set(packetsCount: Int32(packetsCount))
                .set(shift: Int32(leftBound))
                .set(token: token)
                .build(contentType: contentType)

            let packet = Packet(data: chunk, headers: headers)

            packetsQueue.enqueue((packet, host, .now(), 0), priority: .medium)

            packetNumber += 1
            leftBound += packetSize
        }
    }

    private func startCommunicationLoop() {
        while started {
            handleIncomingDatagrams()
            retransmitPackets()
            dropFailedTransmissions()
            sendNextPackets()
        }
    }

    private func handleIncomingDatagrams() {
        var data: Data
        var host: Host

        repeat {
            data = Data()

            do {
                let (count, addressOpt) = try socket.readDatagram(into: &data)

                if count == 0 {
                    break
                }

                guard let address = addressOpt else {
                    break
                }

                guard let hostnameAndPort = Socket.hostnameAndPort(from: address) else {
                    break
                }

                host = (address: hostnameAndPort.hostname, port: hostnameAndPort.port)
            } catch let error {
                print(error.localizedDescription)
                break
            }

            let packet = Packet(encoded: data)

            // Debug
            print("<- \(packet)")

            switch packet.headers.contentType {
            case .acknowledgement:
                congestionWindow.removeAll { packet.isAcknowledgementOf($0.packet) }

                guard let transmission = outcomingTransmissions[host.address]?[packet.headers.messageNumber] else {
                    break
                }

                let address = host.address
                let messageNumber = packet.headers.messageNumber
                let packetNumber = packet.headers.packetNumber

                outcomingTransmissions[address]![messageNumber]!.addAcknowledgement(packetNumber: Int(packetNumber))

                if transmission.done {
                    transmission.complete(success: true)
                }
            case .string, .binary:
                handleDataPacket(packet, origin: host)
            default:
                break
            }
        } while data.count > 0
    }

    private func retransmitPackets() {
        for index in 0..<congestionWindow.count {
            let packetContainer = congestionWindow[index]

            if packetContainer.lastAttemptTime + .milliseconds(retransmittInterval) <= .now() {
                if packetContainer.attemptsCount < maxAttemptsCount {
                    let prefix = String(repeating: "-> ", count: packetContainer.attemptsCount + 1)

                    sendPacket(packetContainer.packet, to: packetContainer.host, logPrefix: prefix)

                    congestionWindow[index].lastAttemptTime = .now()
                }

                congestionWindow[index].attemptsCount += 1
            }
        }
    }

    private func dropFailedTransmissions() {
        let failedPackets = congestionWindow.filter { $0.attemptsCount > maxAttemptsCount }

        failedPackets.forEach { packetContainer in
            let messageNumber = packetContainer.packet.headers.messageNumber
            let address = packetContainer.host.address

            packetsQueue.removeAll {
                $0.packet.headers.messageNumber == messageNumber && $0.host.address == address
            }

            outcomingTransmissions[address]?[messageNumber]?.complete(success: false)
            outcomingTransmissions[address]?.removeValue(forKey: messageNumber)
        }

        congestionWindow.removeAll { $0.attemptsCount > maxAttemptsCount }
    }

    private func sendNextPackets() {
        let congestionWindowIsFull = congestionWindow.count >= congestionWindowSize
        let packetsQueueIsEmpty = packetsQueue.count == 0

        if congestionWindowIsFull || packetsQueueIsEmpty {
            return
        }

        if let packetContainer = packetsQueue.dequeue() {
            let (packet, host, _, _) = packetContainer

            if [.string, .binary].contains(packet.headers.contentType) {
                congestionWindow.append(packetContainer)
                congestionWindow[congestionWindow.count - 1].lastAttemptTime = .now()
                congestionWindow[congestionWindow.count - 1].attemptsCount = 1
            }

            sendPacket(packet, to: host, logPrefix: "-> ")
        }
    }

    private func handleDataPacket(_ packet: Packet, origin host: Host) {
        guard [.string, .binary].contains(packet.headers.contentType) else {
            return
        }

        let acknowledgement = Packet.createAcknowledgement(for: packet)

        sendPacket(acknowledgement, to: host, logPrefix: "->")

        if incomingMessagesCount[host.address] == nil {
            incomingMessagesCount[host.address] = 0
        }

        let messageNumber = packet.headers.messageNumber

        let isObsolete = messageNumber <= incomingMessagesCount[host.address]! && messageNumber != 0
        let isPending = incomingTransmissions[host.address]?[messageNumber] != nil

        if isObsolete && !isPending {
            return
        }

        if messageNumber > incomingMessagesCount[host.address]! {
            incomingMessagesCount[host.address]! += 1
        }

        if incomingTransmissions[host.address] == nil {
            incomingTransmissions[host.address] = [Int64: IncomingTransmission]()
        }

        if incomingTransmissions[host.address]![messageNumber] == nil {
            incomingTransmissions[host.address]![messageNumber] = IncomingTransmission(packet: packet)
        } else {
            incomingTransmissions[host.address]![messageNumber]!.add(packet: packet)
        }

        guard let transmission = incomingTransmissions[host.address]![messageNumber] else {
            return
        }

        if transmission.done {
            guard let message = transmission.message else {
                return
            }

            if packet.headers.contentType == .string {
                guard let text = String(bytes: message, encoding: .utf8) else {
                    return
                }

                delegate?.stringMessageReceived(text)
            } else if packet.headers.contentType == .binary {
                delegate?.binaryMessageReceived(message)
            }

            incomingTransmissions[host.address]!.removeValue(forKey: messageNumber)
        }
    }

    private func sendPacket(_ packet: Packet, to host: Host, logPrefix: String) {
        if let address = Socket.createAddress(for: host.address, on: host.port) {
            do {
                try socket.write(from: packet.encode(), to: address)

                // debug
                print("\(logPrefix) \(packet)")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
