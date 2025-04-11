//
//  CommunityRegistration.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Foundation

struct CommunityRegistration {
    let team: LCKTeam?
    let hasRegisteredTeam: Bool
    
    static func initialState() -> Self {
        return .init(team: nil, hasRegisteredTeam: false)
    }
}
