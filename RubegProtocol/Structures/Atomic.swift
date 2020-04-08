//
//  Atomic.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 08/04/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class Atomic<T> {
    private var _value: T?

    private let lock: DispatchQueue = {
        let label = "atomic_\(UUID().uuidString)"
        return DispatchQueue(label: label, qos: .default, attributes: .concurrent)
    }()

    var value: T? {
        get {
            return lock.sync { _value }
        }

        set {
            lock.async(flags: .barrier) {
                self._value = newValue
            }
        }
    }

    init(_ value: T?) {
        _value = value
    }
}
