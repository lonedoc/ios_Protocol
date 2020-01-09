//
//  OutcomingTransmission.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 26/11/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

class OutcomingTransmission {
    private var acknowledgements: [Bool]
    private let completion: (Bool) -> Void

    init(_ packetsCount: Int, completion: @escaping (Bool) -> Void) {
        acknowledgements = [Bool](repeating: false, count: packetsCount)
        self.completion = completion
    }

    var done: Bool {
        return acknowledgements.allSatisfy { $0 }
    }

    func complete(success: Bool) {
        completion(success)
    }

    func addAcknowledgement(packetNumber: Int) {
        acknowledgements[packetNumber - 1] = true
    }
}
