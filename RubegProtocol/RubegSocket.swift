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

// swiftlint:disable type_body_length file_length
public class RubegSocket {
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

    private let currentMessageNumbers = SynchronizedSet<Int64>()

    private let splittingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private let dropUnexpected: Bool

    public weak var delegate: RubegSocketDelegate?
    @Atomic private(set) var started = false

    public var opened: Bool {
        return started
    }

    public init(dropUnexpected: Bool = true) {
        self.dropUnexpected = dropUnexpected
    }

    public func open() throws {
        if started {
            return
        }

        socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
        try socket?.setBlocking(mode: false)

        started = true

        receivingQueue.async { self.startReceiveLoop() }
        sendingQueue.async { self.startSendLoop() }
    }

    public func close() {
        started = false
    }

    public func reset() {
        currentMessageNumbers.removeAll()
        incomingTransmissions.removeAll()
        outgoingTransmissions.clear()
        outgoingTransmission = nil
        congestionWindow.removeAll()
        receivedAcknowledgements.clear()
        acknowledgements.clear()

        socket?.close()
    }

    public func send(
        message: String,
        token: String?,
        to address: InetAddress,
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
                contentType: .noconnection,
                address: address,
                complete: complete
            )
        }
    }

    public func send(
        message: [Byte],
        token: String?,
        to address: InetAddress,
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
                contentType: .binary,
                address: address,
                progress: progress,
                complete: complete
            )
        }
    }

    private func send(
        data: [Byte],
        token: String?,
        contentType: ContentType,
        address: InetAddress,
        progress: ((Int) -> Void)? = nil,
        complete: @escaping (Bool) -> Void
    ) {
        var messageNumber = Int64.random(in: 0...Int64.max)
        while currentMessageNumbers.contains(messageNumber) {
            messageNumber = Int64.random(in: 0...Int64.max)
        }
        _ = currentMessageNumbers.insert(messageNumber)

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

            transmission.add(packet: PacketContainer(packet, address))

            packetNumber += 1
            leftBound = rightBound
        }
    }

    private func startReceiveLoop() {
        while started {
            guard let read = readPacket() else {
                usleep(ProtocolConstants.sleepInterval)
                continue
            }

            let (packet, host) = read

            #if DEBUG
                print("<- \(packet)")
            #endif

            switch packet.headers.contentType {
            case .acknowledgement:
                receivedAcknowledgements.enqueue(PacketContainer(packet, host))
            case .binary, .string, .noconnection:
                handleDataPacket(packet, host)
            default:
                break
            }

            incomingTransmissions = incomingTransmissions.filter { !$0.value.failed }
        }
    }

    private func readPacket() -> (Packet, InetAddress)? {
        guard let socket = socket else {
            return nil
        }

        var data = Data()
        var address: InetAddress

        do {
            let (count, addressOpt) = try socket.readDatagram(into: &data)

            if count == 0 {
                return nil
            }

            guard let addr = addressOpt else {
                return nil
            }

            guard let hostnameAndPort = Socket.hostnameAndPort(from: addr) else {
                return nil
            }

            address = try InetAddress.create(ip: hostnameAndPort.hostname, port: hostnameAndPort.port)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }

        let packet = Packet(encoded: data)

        return (packet, address)
    }

    private func handleDataPacket(_ packet: Packet, _ address: InetAddress) {
        guard [.string, .binary, .noconnection].contains(packet.headers.contentType) else {
            return
        }

        let acknowledgement = Packet.createAcknowledgement(for: packet)
        acknowledgements.enqueue(PacketContainer(acknowledgement, address))

        let messageNumber = packet.headers.messageNumber

        let isObsolete = dropUnexpected && !currentMessageNumbers.contains(messageNumber) && messageNumber != 0
        let isPending = incomingTransmissions[messageNumber] != nil

        if isObsolete && !isPending {
            return
        }

        if incomingTransmissions[messageNumber] == nil {
            incomingTransmissions[messageNumber] = IncomingTransmission()
        }

        guard let transmission = incomingTransmissions[messageNumber] else {
            return
        }

        transmission.add(packet: packet)

        if transmission.done {
            guard let message = transmission.data else {
                return
            }

            if [.string, .noconnection].contains(packet.headers.contentType) {
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
                handleAcknowledgement(ack!.packet, address: ack!.address)
                ack = receivedAcknowledgements.dequeue()
            }

            retransmitPackets()
            dropFailedTransmissions()
            sendNextPacket()
        }

        splittingQueue.cancelAllOperations()

        if let ot = outgoingTransmission { // swiftlint:disable:this identifier_name
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
    }

    private func handleAcknowledgement(_ acknowledgement: Packet, address: InetAddress) {
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
        for index in 0..<congestionWindow.count {
            let packetContainer = congestionWindow[index]

            let deadline = packetContainer.lastAttemptTime + .milliseconds(ProtocolConstants.retransmitInterval)

            if deadline < .now() {
                if packetContainer.attemptsCount < ProtocolConstants.maxAttemptCount {
                    let prefix = String(
                        repeating: "-> ",
                        count: packetContainer.attemptsCount + 1
                    )

                    sendPacket(
                        packetContainer.packet,
                        to: packetContainer.address,
                        logPrefix: prefix
                    )

                    congestionWindow[index].lastAttemptTime = .now()
                }

                congestionWindow[index].attemptsCount += 1
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

        for num in failedMessageNumbers {
            _ = currentMessageNumbers.remove(num)
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
            usleep(ProtocolConstants.sleepInterval)
            return
        }

        let (packet, host) = packetContainer

        let container = PacketContainerExtended(packet, host, .now(), 1)
        congestionWindow.append(container)

        sendPacket(packet, to: host, logPrefix: "-> ")
    }

    private func sendPacket(_ packet: Packet, to address: InetAddress, logPrefix: String) {
        guard let socket = socket else {
            return
        }

        guard let address =
            Socket.createAddress(for: address.ip, on: address.port)
        else {
            return
        }

        do {
            try socket.write(from: packet.encode(), to: address)

            #if DEBUG
                print("\(logPrefix)\(packet)")
            #endif
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
