//
//  Publisher+UIControlEvent.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/25/25.
//

import Combine
import UIKit

extension Publishers {
    
    // MARK: - Publisher
    
    /// UIKit의 `UIControl` 이벤트를 Combine 퍼블리셔로 변환하는 구조체입니다.
    ///
    /// 이 퍼블리셔는 버튼 탭, 슬라이더 변경, 텍스트 필드 편집 등의 UIKit 이벤트를 관찰하여
    /// 이벤트가 발생할 때마다 `Void` 값을 방출합니다.
    ///
    /// - Note:
    ///   이 퍼블리셔는 실패하지 않으며(`Failure == Never`), 출력값은 항상 `Void`입니다.
    ///   이벤트 발생 시점에만 구독자에게 값이 전달됩니다.
    ///
    /// - Example:
    ///   ```swift
    ///   button.publisher(for: .touchUpInside)
    ///       .sink {
    ///           print("버튼이 눌렸습니다.")
    ///       }
    ///   ```
    struct UIControlEventPublisher<Control: UIControl>: Publisher {
        typealias Output = Void
        typealias Failure = Never
        
        private let control: Control
        private let events: UIControl.Event
        
        /// 퍼블리셔를 생성합니다.
        ///
        /// - Parameters:
        ///   - control: 이벤트를 관찰할 `UIControl` 인스턴스입니다.
        ///   - events: 관찰할 `UIControl.Event` 유형입니다.
        init(control: Control, events: UIControl.Event) {
            self.control = control
            self.events = events
        }
        
        func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            let subscription = UIControlEventSubscription(subscriber: subscriber, control: control, events: events)
            subscriber.receive(subscription: subscription)
        }
    }
    
    // MARK: - Subscription
    
    /// `UIControlEventPublisher`의 구독 객체로, 지정된 이벤트가 발생할 때마다 구독자에게 값을 전달합니다.
    ///
    /// 구독이 활성화되는 동안 지정한 UIControl 이벤트를 감지하고,
    /// 이벤트가 발생하면 `Void` 값을 구독자에게 전달합니다.
    ///
    /// - Note:
    ///   구독이 취소되면 내부적으로 `subscriber` 참조가 해제되어 더 이상 이벤트가 전달되지 않습니다.
    final class UIControlEventSubscription<S: Subscriber, Control: UIControl>: Subscription where S.Input == Void, S.Failure == Never {
        
        private var subscriber: S?
        private weak var control: Control?
        
        /// 구독 객체를 생성하고 이벤트를 감지하도록 설정합니다.
        ///
        /// - Parameters:
        ///   - subscriber: 이벤트를 수신할 Combine 구독자입니다.
        ///   - control: 이벤트를 발생시키는 `UIControl`입니다.
        ///   - events: 수신할 이벤트 유형입니다.
        init(subscriber: S, control: Control, events: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(eventHandler), for: events)
        }
        
        /// 수요 요청 처리 (UI 이벤트는 직접적인 수요와 무관하므로 무시됩니다).
        func request(_ demand: Subscribers.Demand) {}
        
        /// 구독을 취소하고 참조를 해제합니다.
        func cancel() {
            subscriber = nil
        }
        
        /// UIControl 이벤트가 발생했을 때 호출되는 메서드입니다.
        @objc private func eventHandler() {
            _ = subscriber?.receive(())
        }
    }
}

// MARK: - UIControl Extension

extension CombineCompatible where Self: UIControl {
    
    /// 지정된 UIControl 이벤트를 Combine 퍼블리셔로 노출합니다.
    ///
    /// - Parameter events: 관찰할 UIControl 이벤트입니다. 예: `.touchUpInside`, `.editingChanged` 등
    /// - Returns: 지정된 이벤트가 발생할 때 `Void` 값을 방출하는 퍼블리셔
    ///
    /// - Example:
    ///   ```swift
    ///   textField.publisher(for: .editingChanged)
    ///       .sink {
    ///           print("텍스트가 변경되었습니다.")
    ///       }
    ///   ```
    func publisher(for events: UIControl.Event) -> Publishers.UIControlEventPublisher<Self> {
        Publishers.UIControlEventPublisher(control: self, events: events)
    }
}
