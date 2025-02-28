//
//  Opacity.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/1/25.
//

import Foundation

// MARK: - 투명도

struct Opacity {
    static let minValue: Int = -85
    
    private(set) var value: Int
    
    var displayedValue: Int {
        if value <= -81 {
            return 15
        }
        return (100 + value) / 10 * 10
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
