//
//  Socket.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 12/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation
import Socket

struct SocketConstants {
    static let packetSize = 962
    static let connectionDropInterval = 20_000
    static let syncInterval = 3000
    static let retransmitInterval = 10_000
    static let maxAttemptsCount = 3
    static let congestionWindowSize = 24
}

public class RubegSocket {
    private var outcomingMessagesCount = [String: Int64]()
    private var incomingMessagesCount = [String: Int64]()

    private var outcomingTransmissions = [String: [Int64: OutcomingTransmission]]()
    private var incomingTransmissions = [String: [Int64: IncomingTransmission]]()

    private var packetsQueue = PriorityQueue<ExtendedPacketContainer>()
    private var congestionWindow = [ExtendedPacketContainer]()
    private var acksQueue = Queue<PacketContainer>()

    private var socket: Socket

    private var started = false

    private let packagingQueue = DispatchQueue(label: "rubeg_protocol.packaging", qos: .userInitiated)
    private let sendLoopQueue = DispatchQueue(label: "rubeg_protocol.send_loop", qos: .userInitiated)
    private let receiveLoopQueue = DispatchQueue(label: "rubeg_protocol.receive_loop", qos: .userInitiated)

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

        receiveLoopQueue.async {
            self.startReceiveLoop()
        }

        sendLoopQueue.async {
            self.startSendLoop()
        }
    }

    public func close() {
        started = false
    }

    // MARK: Send message

    public func send(message: String, token: String?, to host: Host, completion: @escaping (Bool) -> Void) {
        let data: [Byte] = Array(message.utf8)

        packagingQueue.async {
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
        packagingQueue.async {
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

        var packetsCount = data.count / SocketConstants.packetSize

        if data.count % SocketConstants.packetSize != 0 {
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
            let rightBound = leftBound + SocketConstants.packetSize < data.count ?
                leftBound + SocketConstants.packetSize :
                data.count

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
            leftBound += SocketConstants.packetSize
        }
    }

    // MARK: Send loop

    private func startSendLoop() {
        while started {
            while let ack = acksQueue.dequeue() {
                handleAcknowledgement(ack.packet, origin: ack.host)
            }

            retransmitPackets()
            dropFailedTransmissions()
            sendNextPackets()
        }
    }

    private func handleAcknowledgement(_ acknowledgement: Packet, origin host: Host) {
        guard acknowledgement.headers.contentType == .acknowledgement else {
            return
        }

        congestionWindow.removeAll { acknowledgement.isAcknowledgementOf($0.packet) }

        let address = host.address
        let messageNumber = acknowledgement.headers.messageNumber
        let packetNumber = acknowledgement.headers.packetNumber

        guard let transmission = outcomingTransmissions[address]?[messageNumber] else {
            return
        }

        outcomingTransmissions[address]![messageNumber]!.addAcknowledgement(packetNumber: Int(packetNumber))

        if transmission.done {
            transmission.complete(success: true)
            outcomingTransmissions[address]!.removeValue(forKey: messageNumber)
        }
    }

    private func retransmitPackets() {
        for index in 0..<congestionWindow.count {
            let packetContainer = congestionWindow[index]

            if packetContainer.lastAttemptTime + .milliseconds(SocketConstants.retransmitInterval) <= .now() {
                if packetContainer.attemptsCount < SocketConstants.maxAttemptsCount {
                    let prefix = String(repeating: "-> ", count: packetContainer.attemptsCount + 1)
                    sendPacket(packetContainer.packet, to: packetContainer.host, logPrefix: prefix)

                    congestionWindow[index].lastAttemptTime = .now()
                }

                congestionWindow[index].attemptsCount += 1
            }
        }
    }

    private func dropFailedTransmissions() {
        var failedTransmissions = Set<MessageSignature>()

        congestionWindow.removeAll { packetContainer in
            guard packetContainer.attemptsCount > SocketConstants.maxAttemptsCount else {
                return false
            }

            let messageNumber = packetContainer.packet.headers.messageNumber
            let address = packetContainer.host.address

            failedTransmissions.insert(MessageSignature(messageNumber, address))

            outcomingTransmissions[address]?[messageNumber]?.complete(success: false)
            outcomingTransmissions[address]?.removeValue(forKey: messageNumber)

            return true
        }

        packetsQueue.removeAll { packetContainer in
            let messageNumber = packetContainer.packet.headers.messageNumber
            let address = packetContainer.host.address
            let messageSignature = MessageSignature(messageNumber, address)

            return failedTransmissions.contains(messageSignature)
        }
    }

    private func sendNextPackets() {
        while congestionWindow.count < SocketConstants.congestionWindowSize {
            guard let packetContainer = packetsQueue.dequeue() else {
                break
            }

            let (packet, host, _, _) = packetContainer

            if [.string, .binary].contains(packet.headers.contentType) {
                congestionWindow.append(packetContainer)
                congestionWindow[congestionWindow.count - 1].lastAttemptTime = .now()
                congestionWindow[congestionWindow.count - 1].attemptsCount = 1
            }

            sendPacket(packet, to: host, logPrefix: "-> ")
        }
    }

    private func sendPacket(_ packet: Packet, to host: Host, logPrefix: String) {
        if let address = Socket.createAddress(for: host.address, on: host.port) {
            do {
                try socket.write(from: packet.encode(), to: address)

                // debug
                print("\(logPrefix)\(packet)")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: Receive loop

    private func startReceiveLoop() {
        while started {
            guard let (packet, host) = readPacket() else {
                continue
            }

            // Debug
            print("<- \(packet)")

            switch packet.headers.contentType {
            case .acknowledgement:
                acksQueue.enqueue((packet, host))
            case .string, .binary:
                handleDataPacket(packet, origin: host)
            default:
                continue
            }
        }
    }

    private func readPacket() -> (Packet, Host)? {
        var buffer = Data()
        var host: Host

        do {
            let (count, addressOpt) = try socket.readDatagram(into: &buffer)

            if count == 0 {
                return nil
            }

            guard let address = addressOpt else {
                return nil
            }

            guard let hostnameAndPort = Socket.hostnameAndPort(from: address) else {
                return nil
            }

            host = (address: hostnameAndPort.hostname, port: hostnameAndPort.port)
            let packet = Packet(encoded: buffer)

            return (packet, host)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    private func handleDataPacket(_ packet: Packet, origin host: Host) {
        guard [.string, .binary].contains(packet.headers.contentType) else {
            return
        }

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
            incomingMessagesCount[host.address] = messageNumber
        }

        let acknowledgement = Packet.createAcknowledgement(for: packet)
        let packetContainer: ExtendedPacketContainer = (
            packet: acknowledgement,
            host: host,
            lastAttemptTime: .now(),
            attemptsCount: 0
        )

        packetsQueue.enqueue(packetContainer, priority: .high)

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
            defer {
                incomingTransmissions[host.address]!.removeValue(forKey: messageNumber)
            }

            guard let message = transmission.message else {
                return
            }

            if packet.headers.contentType == .string {
                guard let text = String(bytes: message, encoding: .utf8) else {
                    return
                }

                delegate?.stringMessageReceived(text)
            } else {
                delegate?.binaryMessageReceived(message)
            }
        }
    }
}
