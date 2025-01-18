//
//  NotiInfoText.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/31/24.
//

import Foundation

enum NotiInfoText: String {
    case gameDone = "GAMEDONE"
    case gameStart = "GAMESTART"
    case weekDone = "WEEKDONE"
    
    var text: String {
        switch self {
        case .gameDone:
            return StringLiterals.Notification.gameDone
        case .gameStart:
            return StringLiterals.Notification.gameStart
        case .weekDone:
            return StringLiterals.Notification.weekDone
        }
    }
}
