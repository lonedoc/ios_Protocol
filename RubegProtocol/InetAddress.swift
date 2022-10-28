//
//  Host.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 25.11.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation
import Network

// swiftlint:disable identifier_name
public class InetAddress {
    public let ip: String
    public let port: Int32

    public static func create(ip: String, port: Int32) throws -> InetAddress {
        try validate(ip: ip)
        try validate(port: port)

        return InetAddress(ip: ip, port: port)
    }

    public static func createAll(hosts: [String], port: Int32) -> [InetAddress] {
        if !isValidPort(port) {
            return []
        }

        return hosts.flatMap { host in
            if isIpAddress(hostname: host) {
                if isValidIp(host) {
                    return [InetAddress(ip: host, port: port)]
                } else {
                    return []
                }
            }

            return resolveDomainName(hostname: host)
                .filter { ip in isValidIp(ip) }
                .map { ip in InetAddress(ip: ip, port: port) }
        }
    }

    private static func isIpAddress(hostname: String) -> Bool {
        return hostname.allSatisfy { char in char.isNumber || char == "." }
    }

    private static func resolveDomainName(hostname: String) -> [String] {
        var ips = [String]()

        guard let host = (hostname.withCString { gethostbyname($0) }) else {
            return ips
        }

        guard host.pointee.h_length > 0 else {
            return ips
        }

        var index = 0
        while host.pointee.h_addr_list[index] != nil {
            var addr = in_addr()

            memcpy(&addr.s_addr, host.pointee.h_addr_list[index], Int(host.pointee.h_length))

            guard let remoteIPAsC = inet_ntoa(addr) else {
                return ips
            }

            ips.append(String.init(cString: remoteIPAsC))

            index += 1
        }

        return ips
    }

    private static func validate(ip: String) throws {
        if !isValidIp(ip) {
            throw fatalError("Invalid ip")
        }
    }

    private static func validate(port: Int32) throws {
        if !isValidPort(port) {
            throw fatalError("Invalid port")
        }
    }

    private static func isValidIp(_ ip: String) -> Bool {
        let octetPattern = "(1\\d{1,2}|25[0-5]|2[0-4]\\d|\\d{1,2})"
        let pattern = "(\(octetPattern)\\.){3}\(octetPattern)"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: ip)
    }

    private static func isValidPort(_ port: Int32) -> Bool {
        return port >= 0 && port <= 65535
    }

    private init(ip: String, port: Int32) {
        self.ip = ip
        self.port = port
    }
}
