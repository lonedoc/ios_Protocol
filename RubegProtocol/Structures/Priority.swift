//
//  Priority.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 20/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

enum Priority: Int {
    case low = 0
    case medium = 1
    case high = 2

    static func < (leftOperand: Priority, rightOperand: Priority) -> Bool {
        return leftOperand.rawValue < rightOperand.rawValue
    }

    static func > (leftOperand: Priority, rightOperand: Priority) -> Bool {
        return leftOperand.rawValue > rightOperand.rawValue
    }

    static func == (leftOperand: Priority, rightOperand: Priority) -> Bool {
        return leftOperand.rawValue == rightOperand.rawValue
    }

    static func <= (leftOperand: Priority, rightOperand: Priority) -> Bool {
        return leftOperand.rawValue <= rightOperand.rawValue
    }

    static func >= (leftOperand: Priority, rightOperand: Priority) -> Bool {
        return leftOperand.rawValue >= rightOperand.rawValue
    }
}
