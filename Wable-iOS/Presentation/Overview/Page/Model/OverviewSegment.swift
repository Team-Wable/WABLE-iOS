//
//  OverviewSegment.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/24/25.
//

import Foundation

enum OverviewSegment: Int, CaseIterable {
    case gameSchedule = 0
    case teamRank = 1
    case curation = 2
    case notice = 3

    var title: String {
        switch self {
        case .gameSchedule:
            return "경기"
        case .teamRank:
            return "순위"
        case .curation:
            return "큐레이션"
        case .notice:
            return "공지사항"
        }
    }
}
