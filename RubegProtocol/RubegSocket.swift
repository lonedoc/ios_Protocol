//
//  Socket.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 12/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation
import Socket

private let sendingQueueId = ""
private let receivingQueueId = ""
private let splittingQueueId = ""
private let callbackQueueId = ""

public class RubegSocket {
    private var incomingMessagesCount: Int64 = 0
    private var outgoingMessagesCount: Int64 = 0

    private var incomingTransmissions = [Int64: IncomingTransmission]()
    private var outgoingTransmissions = Queue<OutgoingTransmission>()
    private var outgoingTransmission: OutgoingTransmission?
    private var receivedAcknowledgements = Queue<PacketContainer>()
    private var acknowledgements = Queue<PacketContainer>()
    private var congestionWindow = [PacketContainerExtended]()

    private var socket: Socket?

    private let sendingQueue = DispatchQueue(label: sendingQueueId)
    private let receivingQueue = DispatchQueue(label: receivingQueueId)
    private let callbackQueue = DispatchQueue(label: callbackQueueId)

    private let splittingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private lazy var synchronizer: Synchronizer<String> = {
        let keys = Set(arrayLiteral: sendingQueueId, receivingQueueId)

        return Synchronizer(keys: keys) { [weak self] in
            self?.reset()
        }
    }()

    @Atomic public var delegate: RubegSocketDelegate?
    @Atomic private(set) var started = false

    public func open() throws {
        // TODO: lock

        if started {
            return
        }

        socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
        try socket?.setBlocking(mode: false)

        started = true

        receivingQueue.async { self.startReceiveLoop() }
        sendingQueue.async { self.startSendLoop() }

        // TODO: unlock
    }

    public func close() {
        // TODO: lock

        started = false
    }

    private func reset() {
        incomingMessagesCount = 0
        outgoingMessagesCount = 0

        incomingTransmissions.removeAll()
        outgoingTransmissions.clear()
        outgoingTransmission = nil
        congestionWindow.removeAll()
        receivedAcknowledgements.clear()
        acknowledgements.clear()

        socket?.close()

        // TODO: unlock
    }

    public func send(
        message: String,
        token: String?,
        to host: Host,
        complete: @escaping (Bool) -> Void
    ) {
        if !started {
            complete(false)
        }

        let data: [Byte] = Array(message.utf8)

        splittingQueue.addOperation {
            self.send(
                data: data,
                token: token,
                contentType: .string,
                host: host,
                complete: complete
            )
        }
    }

    public func send(
        message: [Byte],
        token: String?,
        to host: Host,
        progress: ((Int) -> Void)? = nil,
        complete: @escaping (Bool) -> Void
    ) {
        if !started {
            complete(false)
        }

        splittingQueue.addOperation {
            self.send(
                data: message,
                token: token,
                contentType: .string,
                host: host,
                progress: progress,
                complete: complete
            )
        }
    }

    private func send(
        data: [Byte],
        token: String?,
        contentType: ContentType,
        host: Host,
        progress: ((Int) -> Void)? = nil,
        complete: @escaping (Bool) -> Void
    ) {
        outgoingMessagesCount += 1
        let messageNumber = outgoingMessagesCount

        var packetsCount = data.count / ProtocolConstants.packetSize
        if data.count % ProtocolConstants.packetSize != 0 {
            packetsCount += 1
        }

        let transmission = OutgoingTransmission(
            packetsCount: packetsCount,
            messageNumber: messageNumber,
            progress: progress,
            complete: complete
        )

        outgoingTransmissions.enqueue(transmission)

        var packetNumber: Int32 = 1

        var leftBound = 0
        while leftBound < data.count && !transmission.failed {
            var rightBound = leftBound + ProtocolConstants.packetSize

            if rightBound > data.count {
                rightBound = data.count
            }

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

            transmission.add(packet: PacketContainer(packet, host))

            packetNumber += 1
            leftBound = rightBound
        }
    }

    private func startReceiveLoop() {
        while started {
            guard let read = readPacket() else { continue }

            let (packet, host) = read

            print("<- \(packet)")

            switch packet.headers.contentType {
            case .acknowledgement:
                receivedAcknowledgements.enqueue(PacketContainer(packet, host))
            case .binary, .string:
                handleDataPacket(packet, host)
            default:
                break
            }

            incomingTransmissions = incomingTransmissions.filter { !$0.value.failed }
        }

        synchronizer.synchronize(with: receivingQueueId)
    }

    private func readPacket() -> (Packet, Host)? {
        guard let socket = socket else {
            return nil
        }

        var data = Data()
        var host: Host

        do {
            let (count, addressOpt) = try socket.readDatagram(into: &data)

            if count == 0 {
                return nil
            }

            guard let address = addressOpt else {
                return nil
            }

            guard let hostnameAndPort = Socket.hostnameAndPort(from: address) else {
                return nil
            }

            host = (
                address: hostnameAndPort.hostname,
                port: hostnameAndPort.port
            )
        } catch let error {
            print(error.localizedDescription)
            return nil
        }

        let packet = Packet(encoded: data)

        return (packet, host)
    }

    private func handleDataPacket(_ packet: Packet, _ host: Host) {
        guard [.string, .binary].contains(packet.headers.contentType) else {
            return
        }

        let acknowledgement = Packet.createAcknowledgement(for: packet)
        acknowledgements.enqueue(PacketContainer(acknowledgement, host))

        let messageNumber = packet.headers.messageNumber

        let isObsolete = messageNumber <= incomingMessagesCount && messageNumber != 0
        let isPending = incomingTransmissions[messageNumber] != nil

        if isObsolete && !isPending {
            return
        }

        if messageNumber > incomingMessagesCount {
            incomingMessagesCount = messageNumber
        }

        if incomingTransmissions[messageNumber] == nil {
            incomingTransmissions[messageNumber] =
                IncomingTransmission(packet: packet)
        }

        guard let transmission = incomingTransmissions[messageNumber] else {
            return
        }

        transmission.add(packet: packet)

        if transmission.done {
            guard let message = transmission.data else {
                return
            }

            if packet.headers.contentType == .string {
                guard let text = String(bytes: message, encoding: .utf8) else {
                    return
                }

                callbackQueue.async {
                    self.delegate?.stringMessageReceived(text)
                }
            } else {
                callbackQueue.async {
                    self.delegate?.binaryMessageReceived(message)
                }
            }

            incomingTransmissions.removeValue(forKey: messageNumber)
        }
    }

    private func startSendLoop() {
        while started {
            var ack = receivedAcknowledgements.dequeue()

            while ack != nil {
                handleAcknowledgement(ack!.packet, host: ack!.host)
                ack = receivedAcknowledgements.dequeue()
            }

            retransmitPackets()
            dropFailedTransmissions()
            sendNextPacket()
        }

        splittingQueue.cancelAllOperations()

        if let ot = outgoingTransmission {
            callbackQueue.async {
                ot.onComplete(false)
            }
        }

        outgoingTransmission = nil

        var transmission = outgoingTransmissions.dequeue()
        while let currentTransmission = transmission {
            callbackQueue.async {
                currentTransmission.onComplete(false)
            }

            transmission = outgoingTransmissions.dequeue()
        }

        synchronizer.synchronize(with: sendingQueueId)
    }

    private func handleAcknowledgement(_ acknowledgement: Packet, host: Host) {
        guard acknowledgement.headers.contentType == .acknowledgement else {
            return
        }

        guard let index = (congestionWindow.firstIndex { acknowledgement.isAcknowledgementOf($0.packet)
        }) else {
            return
        }

        congestionWindow.remove(at: index)

        guard let transmission = outgoingTransmission else {
            return
        }

        if transmission.messageNumber != acknowledgement.headers.messageNumber {
            return
        }

        let packetNumber = acknowledgement.headers.packetNumber
        transmission.addAcknowledgement(packetNumber: Int(packetNumber))

        if let onProgress = transmission.onProgress {
            callbackQueue.async {
                onProgress(transmission.progress)
            }
        }

        if transmission.done {
            callbackQueue.async {
                transmission.onComplete(true)
            }

            outgoingTransmission = nil
        }
    }

    private func retransmitPackets() {
        congestionWindow.forEach { packetContainer in
            let deadline = packetContainer.lastAttemptTime + .milliseconds(ProtocolConstants.retransmitInterval)

            if deadline < .now() {
                if packetContainer.attemptsCount < ProtocolConstants.maxAttemptCount {
                    let prefix = String(
                        repeating: "-> ",
                        count: packetContainer.attemptsCount + 1
                    )

                    sendPacket(
                        packetContainer.packet,
                        to: packetContainer.host,
                        logPrefix: prefix
                    )
                }
            }
        }
    }

    private func dropFailedTransmissions() {
        var failedMessageNumbers = Set<Int64>()

        for (index, packetConainer) in congestionWindow.enumerated() {
            let messageNumber = packetConainer.packet.headers.messageNumber

            if packetConainer.attemptsCount > ProtocolConstants.maxAttemptCount {
                failedMessageNumbers.insert(messageNumber)
                congestionWindow.remove(at: index)
                continue
            }

            if failedMessageNumbers.contains(messageNumber) {
                congestionWindow.remove(at: index)
            }
        }

        guard let currentTransmission = outgoingTransmission else {
            return
        }

        if failedMessageNumbers.contains(currentTransmission.messageNumber) {
            callbackQueue.async {
                currentTransmission.onComplete(false)
            }

            outgoingTransmission?.failed = true
            outgoingTransmission = nil
        }
    }

    private func sendNextPacket() {
        if congestionWindow.count >= ProtocolConstants.congestionWindowSize {
            return
        }

        if let acknowledgementContainer = acknowledgements.dequeue() {
            let (packet, host) = acknowledgementContainer
            sendPacket(packet, to: host, logPrefix: "-> ")
            return
        }

        outgoingTransmission = outgoingTransmission ?? outgoingTransmissions.dequeue()

        guard let packetContainer = outgoingTransmission?.getNextPacket() else {
            sleep(ProtocolConstants.sleepInterval)
            return
        }

        let (packet, host) = packetContainer

        let container = PacketContainerExtended(packet, host, .now(), 1)
        congestionWindow.append(container)

        sendPacket(packet, to: host, logPrefix: "-> ")
    }

    private func sendPacket(_ packet: Packet, to host: Host, logPrefix: String) {
        guard let socket = socket else {
            return
        }

        guard let address =
            Socket.createAddress(for: host.address, on: host.port)
        else {
            return
        }

        do {
            try socket.write(from: packet.encode(), to: address)

            print("\(logPrefix)\(packet)")
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
