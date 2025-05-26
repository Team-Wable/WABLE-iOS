//
//  Publishers+UIControlProperty.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/25/25.
//

import Combine
import UIKit

extension Publishers {
    
    // MARK: - UIControlPropertyPublisher
    
    /// `UIControl`의 특정 속성 값을 Combine 퍼블리셔로 노출하는 퍼블리셔입니다.
    ///
    /// 지정된 UIControl 이벤트가 발생할 때마다, 해당 시점의 `keyPath`로 접근한 속성 값을 방출합니다.
    ///
    /// 예를 들어, `UITextField`의 `.editingChanged` 이벤트가 발생할 때마다 `text` 속성 값을 방출할 수 있습니다.
    ///
    /// - Parameters:
    ///   - Control: 퍼블리싱할 UIControl 타입입니다. 예: `UITextField`, `UISwitch`, `UISlider`
    ///   - Output: 해당 컨트롤에서 `keyPath`로 접근할 수 있는 속성의 타입입니다.
    ///
    /// - Note:
    ///   이 퍼블리셔는 실패하지 않으며(`Failure == Never`), 이벤트가 발생한 시점의 속성 값만 방출합니다.
    ///
    /// - Example:
    ///   ```swift
    ///   textField.publisher(for: .editingChanged, keyPath: \.text)
    ///       .sink { text in
    ///           print("텍스트가 변경됨: \(text ?? "")")
    ///       }
    ///   ```
    struct UIControlPropertyPublisher<Control: UIControl, Output>: Publisher {
        typealias Failure = Never
        
        private let control: Control
        private let events: UIControl.Event
        private let keyPath: KeyPath<Control, Output>
        
        /// 퍼블리셔를 초기화합니다.
        ///
        /// - Parameters:
        ///   - control: 이벤트를 관찰할 `UIControl` 인스턴스
        ///   - events: 관찰할 `UIControl.Event` (예: `.valueChanged`, `.editingChanged`)
        ///   - keyPath: 이벤트가 발생했을 때 읽을 속성의 KeyPath
        init(control: Control, events: UIControl.Event, keyPath: KeyPath<Control, Output>) {
            self.control = control
            self.events = events
            self.keyPath = keyPath
        }
        
        func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
            let subscription = UIControlPropertySubscription(
                subscriber: subscriber,
                control: control,
                events: events,
                keyPath: keyPath
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    // MARK: - UIControlPropertySubscription
    
    /// `UIControlPropertyPublisher`의 구독 객체로, 지정된 이벤트가 발생할 때마다 구독자에게 속성 값을 전달합니다.
    ///
    /// 이벤트가 발생한 시점에 해당 컨트롤의 지정된 KeyPath를 통해 값을 읽어 구독자에게 전달합니다.
    final class UIControlPropertySubscription<S: Subscriber, Control: UIControl, Output>: Subscription where S.Input == Output {
        
        private var subscriber: S?
        private weak var control: Control?
        private let events: UIControl.Event
        private let keyPath: KeyPath<Control, Output>
        
        /// 구독 객체를 생성하고 UIControl의 이벤트를 감지합니다.
        ///
        /// - Parameters:
        ///   - subscriber: 값을 수신할 Combine 구독자
        ///   - control: 이벤트를 발생시키는 UIControl
        ///   - event: 관찰할 UIControl.Event
        ///   - keyPath: 이벤트 발생 시 값을 읽을 속성의 KeyPath
        init(subscriber: S, control: Control, events: UIControl.Event, keyPath: KeyPath<Control, Output>) {
            self.subscriber = subscriber
            self.control = control
            self.events = events
            self.keyPath = keyPath
            control.addTarget(self, action: #selector(eventHandler), for: events)
        }
        
        /// 수요 요청은 UI 기반 이벤트 스트림에서 무시됩니다.
        func request(_ demand: Subscribers.Demand) {}
        
        /// 구독을 취소하고 참조를 해제합니다.
        func cancel() {
            control?.removeTarget(self, action: #selector(eventHandler), for: events)
            subscriber = nil
        }
        
        /// 이벤트 발생 시 KeyPath 값을 구독자에게 전달합니다.
        @objc private func eventHandler() {
            guard let control = control else { return }
            _ = subscriber?.receive(control[keyPath: keyPath])
        }
    }
}

// MARK: - UIControl Extension

extension CombineCompatible where Self: UIControl {
    
    /// `UIControl`의 속성 값을 Combine 퍼블리셔로 변환합니다.
    ///
    /// 지정된 이벤트가 발생할 때마다 `KeyPath`를 통해 속성 값을 읽고 방출합니다.
    ///
    /// - Parameters:
    ///   - events: 관찰할 UIControl 이벤트입니다. 예: `.valueChanged`, `.editingChanged` 등
    ///   - keyPath: 이벤트 발생 시 읽을 속성의 KeyPath
    /// - Returns: 이벤트 발생 시 속성 값을 방출하는 Combine 퍼블리셔
    ///
    /// - Example:
    ///   ```swift
    ///   switchControl.publisher(for: .valueChanged, keyPath: \.isOn)
    ///       .sink { isOn in
    ///           print("스위치 상태: \(isOn)")
    ///       }
    ///   ```
    func publisher<Value>(
        for events: UIControl.Event,
        keyPath: KeyPath<Self, Value>
    ) -> Publishers.UIControlPropertyPublisher<Self, Value> {
        return Publishers.UIControlPropertyPublisher(control: self, events: events, keyPath: keyPath)
    }
}
