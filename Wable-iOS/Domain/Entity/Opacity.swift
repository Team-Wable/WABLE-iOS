//
//  Opacity.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/1/25.
//

import Foundation

// MARK: - 투명도
/// 서버에서 넘어올 때 0~-100 사이 정수로 전달

struct Opacity: Hashable {
    static let minValue: Int = -85
    
    private(set) var value: Int
    
    var displayedValue: Int {
        return 100 + value
    }
    
    var alpha: Float {
        if value <= -81 {
            return 0.15
        }
        
        let groupNumber = (abs(value) - 1) / 10 + 1
        let opacityValue = 1.0 - (Float(groupNumber) * 0.1)
        
        return max(0.1, opacityValue)
    }
    
    init(value: Int) {
        self.value = max(Self.minValue, min(0, value))
    }
    
    mutating func reduce() {
        if value > Self.minValue {
            value -= 1
        }
    }
}
