//
//  GameStatus.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/1/25.
//

import Foundation

// MARK: - 게임 진행 상태

enum GameStatus: String {
    case scheduled = "SCHEDULED"
    case progress = "PROGRESS"
    case termination = "TERMINATION"
}
