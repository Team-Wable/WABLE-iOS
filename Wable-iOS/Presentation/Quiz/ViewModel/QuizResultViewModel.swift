//
//  QuizResultViewModel.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/22/25.
//


import Combine
import Foundation

public final class QuizResultViewModel {
    
    // MARK: Property
    
    private let answer: Bool
    private let totalTime: Int
    
    // MARK: - LifeCycle
    
    init(answer: Bool, totalTime: Int) {
        self.answer = answer
        self.totalTime = totalTime
    }
}
