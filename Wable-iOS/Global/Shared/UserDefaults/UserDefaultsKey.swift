//
//  UserDefaultsKey.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/7/25.
//

import Foundation

/// UserDefaults에 접근하기 위한 Key의 타입을 정의하는 프로토콜
///
/// 아래와 같이, 열거형으로 구현한다.
///
/// ```swift
/// enum UserDefaultsKeys: UserDefaultsKey {
///     case userInfo
///
///     var value: String {
///         switch self{
///         case .userInfo:
///             return "userInfo"
///         }
///     }
/// }
/// ```
protocol UserDefaultsKey: Hashable, CaseIterable {
    var value: String { get }
}
