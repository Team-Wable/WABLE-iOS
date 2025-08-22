//
//  Publishers+UIGesture.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/25/25.
//

import Combine
import UIKit

extension Publishers {
    
    // MARK: - GestureType
    
    /// UIView에 적용할 수 있는 다양한 제스처 타입을 나타내는 열거형입니다.
    ///
    /// 각각의 케이스는 해당 제스처 리코그나이저의 인스턴스를 가지고 있으며,
    /// 이를 통해 구체적인 제스처 설정을 커스터마이징할 수 있습니다.
    ///
    /// - Cases:
    ///   - tap: `UITapGestureRecognizer`
    ///   - swipe: `UISwipeGestureRecognizer`
    ///   - longPress: `UILongPressGestureRecognizer`
    ///   - pan: `UIPanGestureRecognizer`
    ///   - pinch: `UIPinchGestureRecognizer`
    ///   - edge: `UIScreenEdgePanGestureRecognizer`
    enum GestureType {
        case tap(UITapGestureRecognizer = .init())
        case swipe(UISwipeGestureRecognizer = .init())
        case longPress(UILongPressGestureRecognizer = .init())
        case pan(UIPanGestureRecognizer = .init())
        case pinch(UIPinchGestureRecognizer = .init())
        case edge(UIScreenEdgePanGestureRecognizer = .init())
        
        /// 현재 열거형에 해당하는 `UIGestureRecognizer` 인스턴스를 반환합니다.
        var gesture: UIGestureRecognizer {
            switch self {
            case let .tap(gesture): return gesture
            case let .swipe(gesture): return gesture
            case let .longPress(gesture): return gesture
            case let .pan(gesture): return gesture
            case let .pinch(gesture): return gesture
            case let .edge(gesture): return gesture
            }
        }
    }
    
    // MARK: - GesturePublisher
    
    /// `UIView`의 제스처 이벤트를 Combine 퍼블리셔로 변환하는 구조체입니다.
    ///
    /// 지정된 제스처가 발생할 때마다 해당 `GestureType`을 방출합니다.
    ///
    /// - Output: `GestureType`
    /// - Failure: `Never` (실패하지 않음)
    ///
    /// - Example:
    ///   ```swift
    ///   view.gesture(.tap())
    ///       .sink { _ in
    ///           print("탭 제스처 인식됨")
    ///       }
    ///   ```
    struct GesturePublisher: Publisher {
        typealias Output = GestureType
        typealias Failure = Never
        
        private weak var view: UIView?
        private let gestureType: GestureType
        
        /// 퍼블리셔를 초기화합니다.
        ///
        /// - Parameters:
        ///   - view: 제스처를 감지할 `UIView` 객체입니다.
        ///   - gestureType: 감지할 제스처 타입입니다.
        init(view: UIView, gestureType: GestureType) {
            self.view = view
            self.gestureType = gestureType
        }
        
        func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            let subscription = GestureSubscription(
                subscriber: subscriber,
                view: view,
                gestureType: gestureType
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    // MARK: - GestureSubscription
    
    /// `GesturePublisher`에 대한 구독 객체로, 지정된 제스처가 발생할 때마다 구독자에게 이벤트를 전달합니다.
    ///
    /// 제스처 인식기를 UIView에 등록하고, 제스처가 발생하면 `GestureType`을 구독자에게 전달합니다.
    final class GestureSubscription<S: Subscriber>: Subscription where S.Input == GestureType, S.Failure == Never {
        
        private var subscriber: S?
        private weak var view: UIView?
        private let gestureType: GestureType
        private var gestureRecognizer: UIGestureRecognizer?
        
        /// 구독 객체를 생성하고 제스처 인식기를 설정합니다.
        ///
        /// - Parameters:
        ///   - subscriber: 이벤트를 수신할 구독자
        ///   - view: 제스처가 적용될 `UIView`
        ///   - gestureType: 감지할 제스처의 종류
        init(subscriber: S, view: UIView?, gestureType: GestureType) {
            self.subscriber = subscriber
            self.view = view
            self.gestureType = gestureType
            self.configureGesture()
        }
        
        /// 제스처 인식기를 UIView에 추가합니다.
        private func configureGesture() {
            let recognizer = gestureType.gesture
            recognizer.addTarget(self, action: #selector(handler))
            view?.addGestureRecognizer(recognizer)
            self.gestureRecognizer = recognizer
        }
        
        /// 수요 요청은 UI 이벤트 기반이므로 무시됩니다.
        func request(_ demand: Subscribers.Demand) { }
        
        /// 구독을 취소하고 제스처 인식기를 제거합니다.
        func cancel() {
            if let recognizer = gestureRecognizer {
                view?.removeGestureRecognizer(recognizer)
            }
            subscriber = nil
        }
        
        /// 제스처가 발생했을 때 호출되며, 구독자에게 이벤트를 전달합니다.
        @objc private func handler() {
            _ = subscriber?.receive(gestureType)
        }
    }
}

// MARK: - UIView Extension

extension UIView {
    
    /// `UIView`에 제스처 퍼블리셔를 연결합니다.
    ///
    /// 지정한 제스처가 발생할 때마다 Combine 스트림으로 `GestureType` 값을 방출합니다.
    ///
    /// - Parameter gestureType: 감지할 제스처의 타입입니다. 기본값은 `.tap()`.
    /// - Returns: `GesturePublisher` 인스턴스로, Combine을 통해 제스처 이벤트를 처리할 수 있습니다.
    ///
    /// - Example:
    ///   ```swift
    ///   someView.gesture(.longPress())
    ///       .sink { _ in
    ///           print("롱 프레스 인식됨")
    ///       }
    ///   ```
    func gesture(_ gestureType: Publishers.GestureType = .tap()) -> Publishers.GesturePublisher {
        self.isUserInteractionEnabled = true
        return Publishers.GesturePublisher(view: self, gestureType: gestureType)
    }
}
