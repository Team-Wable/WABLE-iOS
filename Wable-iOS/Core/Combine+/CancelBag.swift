//
//  CancelBag.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/13/25.
//

import Combine
import Foundation

final class CancelBag {
    fileprivate var subscriptions: Set<AnyCancellable> = .init()
    
    deinit {
        self.cancel()
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
