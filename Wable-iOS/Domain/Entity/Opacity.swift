//
//  Opacity.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/1/25.
//

import Foundation

/// 사용자의 투명도를 관리하는 구조체.
/// 서버에서는 0~-100 사이의 정수로 전달되며, 앱에서는 이를 투명도 백분율과 실제 UI에 적용할 alpha 값으로 변환합니다.
///
/// 사용 예시:
/// ```swift
/// // 서버에서 받은 값으로 초기화
/// let opacity = Opacity(value: -30)
///
/// // 화면에 표시할 백분율 값 (70%)
/// label.text = "\(opacity.displayedValue)%"
///
/// // 실제 UI 요소에 적용할 alpha 값 (0.7)
/// view.alpha = CGFloat(opacity.alpha)
///
/// // 투명도 감소 (신고 등으로 인해)
/// var userOpacity = Opacity(value: -10)
/// userOpacity.reduce()  // value가 -11로 변경됨
/// ```
struct Opacity: Hashable {
    /// 투명도의 최소값 (-85)
    /// 이 값보다 낮아질 수 없음
    static let minValue: Int = -85
    
    /// 실제 투명도 값 (서버에서 받은 값, 0 ~ -100 사이)
    private(set) var value: Int
    
    /// 사용자에게 표시되는 백분율 값 (100% ~ 15%)
    /// 서버 값(value)에 100을 더해 양수로 변환
    var displayedValue: Int {
        return 100 + value
    }
    
    /// UI에 실제 적용할 alpha 값 (1.0 ~ 0.15)
    /// -81 이하는 0.15로 고정, 나머지는 10단위로 그룹화하여 계단식으로 감소
    var alpha: Float {
        if value <= -81 {
            return 0.15 // 최소 투명도
        }
        
        // 10 단위로 그룹화하여 opacity 설정
        // -1~-10: 0.9, -11~-20: 0.8, -21~-30: 0.7 ...
        let groupNumber = (abs(value) - 1) / 10 + 1
        let opacityValue = 1.0 - (Float(groupNumber) * 0.1)
        
        return max(0.1, opacityValue)
    }
    
    /// 투명도 값으로 초기화
    /// - Parameter value: 서버에서 받은 투명도 값 (0 ~ -85)
    /// 입력 값은 0 ~ minValue 사이로 제한됨
    init(value: Int) {
        self.value = max(Self.minValue, min(0, value))
    }
    
    /// 투명도를 한 단계 감소시키는 메서드 (신고/차단 등으로 인한 감소)
    /// minValue에 도달하면 더 이상 감소하지 않음
    mutating func reduce() {
        if value > Self.minValue {
            value -= 1
        }
    }
    
    func reduced() -> Opacity {
        var newValue = value
        if newValue > Self.minValue {
            newValue -= 1
        }
        return Opacity(value: newValue)
    }
}
