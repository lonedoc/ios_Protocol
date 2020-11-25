//
//  Host.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 25.11.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
public class InetAddress {
    public let ip: String
    public let port: Int32

    public static func create(ip: String, port: Int32) throws -> InetAddress {
        try validate(ip: ip)
        try validate(port: port)

        return InetAddress(ip: ip, port: port)
    }

    private static func validate(ip: String) throws {
        let pattern = "((1\\d{1,2}|25[0-5]|2[0-4]\\d|\\d{1,2})\\.){3}(1\\d{1,2}|25[0-5]|2[0-4]\\d|\\d{1,2})"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)

        if !predicate.evaluate(with: ip) {
            throw fatalError("Invalid ip")
        }
    }

    private static func validate(port: Int32) throws {
        if port < 0 || port > 65535 {
            throw fatalError("Invalid port")
        }
    }

    private init(ip: String, port: Int32) {
        self.ip = ip
        self.port = port
    }
}
