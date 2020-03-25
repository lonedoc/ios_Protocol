//
//  RubegSocketDelegate.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 25/03/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

public protocol RubegSocketDelegate: class {
    func stringMessageReceived(_ message: String)
    func binaryMessageReceived(_ message: [Byte])
}
