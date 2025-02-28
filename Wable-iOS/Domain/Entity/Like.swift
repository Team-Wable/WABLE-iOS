//
//  Like.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/1/25.
//

import Foundation

// MARK: - 좋아요

struct Like {
    private(set) var status: Bool
    private(set) var count: Int
    
    mutating func like() {
        status = true
        count += 1
    }
    
    mutating func unlike() {
        status = false
        if count > 0 {
            count -= 1
        }
    }
}
