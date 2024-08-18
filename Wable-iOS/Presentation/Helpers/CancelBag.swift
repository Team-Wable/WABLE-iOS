//
//  CancelBag.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import Combine
import Foundation

final class CancelBag {
    var subscriptions = Set<AnyCancellable>()
    
    func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    init() {}
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
