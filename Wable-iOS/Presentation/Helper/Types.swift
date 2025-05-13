//
//  Types.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Combine
import UIKit

// MARK: - UICollectionView Types

typealias CellRegistration = UICollectionView.CellRegistration
typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration

// MARK: - Combine Driver

typealias Driver<T> = AnyPublisher<T, Never>

// MARK: - Combine PublishRelay & BehaviorRelay

typealias PassthroughRelay<T> = PassthroughSubject<T, Never>
typealias CurrentValueRelay<T> = CurrentValueSubject<T, Never>

// MARK: - Closure

typealias VoidClosure = () -> Void
