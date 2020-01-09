//
//  SyncronizedArray.swift
//  RubegProtocol
//
//  Created by Rubeg NPO on 05/01/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class SynchronizedArray<T> {
    private var items = [T]()
    private let lockQueue = DispatchQueue(label: "rubeg_protocol.sync_array", qos: .default, attributes: .concurrent)
    
    func append(_ item: T) {
        lockQueue.sync {
            self.items.append(item)
        }
    }
    
    func removeAll(where predicate: (T) -> Bool) {
        lockQueue.sync {
            self.items.removeAll(where: predicate)
        }
    }
    
    func removeAll() {
        lockQueue.sync {
            self.items.removeAll()
        }
    }
    
    func forEach(_ action: (T) -> Void) {
        lockQueue.sync {
            self.items.forEach(action)
        }
    }
}
