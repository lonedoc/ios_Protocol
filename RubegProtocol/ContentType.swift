//
//  ContentType.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 17/12/2019.
//  Copyright © 2019 Rubeg NPO. All rights reserved.
//

import Foundation

enum ContentType: Byte {
    case acknowledgement = 0xFF
    case sync = 0xFE
    case error = 0xFD
    case string = 0x00
    case binary = 0x01
}
