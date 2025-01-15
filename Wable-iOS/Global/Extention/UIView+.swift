//
//  UIView+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import Combine
import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    func makeDivisionLine() -> UIView {
        let divisionLine = UIView()
        divisionLine.backgroundColor = .gray300
        return divisionLine
    }
    
    func isValidInput(_ input: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[가-힣a-zA-Z0-9]+$", options: .caseInsensitive)
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        return matches.count > 0
    }
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}

// MARK: - UIGestureRecognizer Combine Publisher

extension UIView {
    func gesturePublisher<T: UIGestureRecognizer>(_ gestureRecognizer: T) -> AnyPublisher<T, Never> {
        GesturePublisher(view: self, gestureRecognizer: gestureRecognizer).eraseToAnyPublisher()
    }
}

// MARK: - GesturePublisher 정의

struct GesturePublisher<T: UIGestureRecognizer>: Publisher {
    typealias Output = T
    typealias Failure = Never
    
    private let view: UIView
    private let gestureRecognizer: T

    init(view: UIView, gestureRecognizer: T) {
        self.view = view
        self.gestureRecognizer = gestureRecognizer
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = GestureSubscription(subscriber: subscriber, view: view, gestureRecognizer: gestureRecognizer)
        subscriber.receive(subscription: subscription)
    }
}

// MARK: - GestureSubscription 정의

final class GestureSubscription<S: Subscriber, T: UIGestureRecognizer>: Subscription where S.Input == T {
    private var subscriber: S?
    private let gestureRecognizer: T
    private weak var view: UIView?

    init(subscriber: S, view: UIView, gestureRecognizer: T) {
        self.subscriber = subscriber
        self.gestureRecognizer = gestureRecognizer
        self.view = view

        self.view?.isUserInteractionEnabled = true
        self.view?.addGestureRecognizer(gestureRecognizer)
        self.gestureRecognizer.addTarget(self, action: #selector(handleGesture))
    }

    func request(_ demand: Subscribers.Demand) {
    }

    func cancel() {
        subscriber = nil
        view?.removeGestureRecognizer(gestureRecognizer)
    }

    @objc private func handleGesture() {
        _ = subscriber?.receive(gestureRecognizer)
    }
}
