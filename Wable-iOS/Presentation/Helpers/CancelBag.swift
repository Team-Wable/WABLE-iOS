//
//  CancelBag.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import Combine

final class CancelBag {
    fileprivate var subscriptions = Set<AnyCancellable>()
    
    deinit {
        cancel()
    }
    
    func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
