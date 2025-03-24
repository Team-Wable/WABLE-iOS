//
//  GameScheduleViewItem.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Foundation

struct GameScheduleViewItem {
    let gameType: String
    let gameSchedules: [GameSchedule]
    
    var isEmpty: Bool { gameSchedules.isEmpty }
}
