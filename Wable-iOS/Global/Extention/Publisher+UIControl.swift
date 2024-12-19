//
//  Publisher+UIControl.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import Combine
import UIKit

protocol CombineCompatible {}

extension UIControl: CombineCompatible {}

extension CombineCompatible where Self: UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        return UIControlPublisher(control: self, events: events)
    }
}

extension CombineCompatible where Self: UIRefreshControl {
    var refreshControlPublisher: UIControlPublisher<Self> {
        return UIControlPublisher(control: self, events: .valueChanged)
    }
}

final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

struct UIControlPublisher<Control: UIControl>: Publisher {

    public typealias Output = Control
    public typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == UIControlPublisher.Failure,
                                                S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

extension Publisher {
    /// 네트워크 통신 후 뷰 모델에서 에러를 단순히 출력할 때 사용합니다.
    func mapWableNetworkError() -> Publishers.MapError<Self, Failure> where Failure == BaseAPI.WableNetworkError {
        self.mapError { error in
            Swift.print("\(error)")
            return error
        }
    }
}

extension Publisher {
    /// 이 메서드는 클로저 내부에서 `owner`를 약한 참조(`weak`)로 캡처하여
    /// 메모리 순환 참조를 방지하고, `owner`가 존재하지 않을 경우 값을 무시합니다.
    ///
    /// - Parameters:
    ///   - owner: `AnyObject` 타입의 소유 객체로, 주로 뷰 컨트롤러와 같은 객체를 전달합니다.
    ///
    /// - Returns: 소유 객체(`owner`)와 Publisher의 Output 값을 튜플로 반환하는 `AnyPublisher`.
    ///   만약 `owner`가 메모리에서 해제되었다면 해당 값은 무시되고, 이벤트는 발생하지 않습니다.
    ///
    /// - 사용 예:
    ///   ```
    ///   myPublisher
    ///       .withUnretained(self)
    ///       .sink { owner, value in
    ///           // `owner`는 안전하게 접근 가능하며, 해제되었을 경우 이벤트가 전달되지 않습니다.
    ///           print("\(owner)의 값: \(value)")
    ///       }
    ///   ```
    ///
    func withUnretained<Object: AnyObject>(_ owner: Object) -> AnyPublisher<(Object, Output), Failure> {
        self.compactMap { [weak owner] value in
            guard let owner else { return nil }
            return (owner, value)
        }
        .eraseToAnyPublisher()
    }
}
