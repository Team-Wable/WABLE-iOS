//
//  InformationNotificationType+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/30/25.
//

import Foundation

extension InformationNotificationType {
    var message: String {
        switch self {
        case .gameDone:
            return "오늘 경기가 끝났어요. 결과를 확인해 보세요!"
        case .gameStart:
            return "이제 곧 경기가 시작해요! 얼른 치킨 시키고 보러 갈까요?"
        case .weekDone:
            return "이번 주 경기가 끝났어요. 다음주에 진행될 경기 일정이 나왔으니 확인해 보세요!"
        }
    }
}
