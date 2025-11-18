//
//  CancelBag.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/13/25.
//

import Combine
import Foundation

final class CancelBag: @unchecked Sendable {
    private let lock = NSLock()

    fileprivate var subscriptions: Set<AnyCancellable> = .init()
    
    deinit {
        self.cancel()
    }
    
    func cancel() {
        self.lock.work {
            subscriptions.forEach { $0.cancel() }
            subscriptions.removeAll()
        }
    }
    
    func store(_ cancellable: AnyCancellable) {
        lock.work {
            subscriptions.insert(cancellable)
        }
    }
}

private extension NSLock {
    func work(_ work: () -> Void) {
        self.lock()
        defer { self.unlock() }
        work()
    }
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.store(self)
    }
}
