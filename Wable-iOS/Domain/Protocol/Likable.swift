//
//  Likable.swift
//  Wable-iOS
//
//  Created by YOUJIM on 8/4/25.
//


import Foundation

protocol Likable {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    
    mutating func like()
    mutating func unlike()
}

extension Likable {
    mutating func like() {
        guard !isLiked else { return }
        isLiked = true
        likeCount += 1
    }
    
    mutating func unlike() {
        guard isLiked else { return }
        isLiked = false
        if likeCount > 0 {
            likeCount -= 1
        }
    }
}
