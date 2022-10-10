//
//  InetAddressTests.swift
//  RubegProtocolTests
//
//  Created by Rubeg NPO on 10.10.2022.
//  Copyright © 2022 Rubeg NPO. All rights reserved.
//

import XCTest
@testable import RubegProtocol

class InetAddressTests: XCTestCase {
    func testThatDomainNameRosolvedCorrectly() {
        let addresses = InetAddress.createAll(
            hosts: ["lk.rubeg38.ru", "192.168.2.110"],
            port: 3000
        )

        XCTAssertTrue(addresses.contains { address in address.ip == "91.189.160.38" })
        XCTAssertTrue(addresses.contains { address in address.ip == "87.103.172.170" })
        XCTAssertTrue(addresses.contains { address in address.ip == "192.168.2.110" })
        XCTAssertTrue(addresses.allSatisfy { address in address.port == 3000 })
    }
}
