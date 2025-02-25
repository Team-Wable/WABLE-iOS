//
//  ProfileMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum ProfileMapper { }

extension ProfileMapper {
    static func toDomain(_ response: DTO.Response.FetchAccountInfo) -> AccountInfo {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        let createdDate = dateFormatter.date(from: response.joinDate)
        let socialPlatform = SocialPlatform(rawValue: response.socialPlatform)
        
        return AccountInfo(
            memberID: response.memberID,
            createdDate: createdDate,
            displayMemberID: response.showMemberID,
            socialPlatform: socialPlatform,
            version: response.versionInformation
        )
    }
    
    static func toDomain(_ response: DTO.Response.FetchUserProfile) -> UserProfile {
        let url = URL(string: response.memberProfileURL)
        let fanTeam = LCKTeam(rawValue: response.memberFanTeam)
        
        return UserProfile(
            user: User(
                id: response.memberID,
                nickname: response.nickname,
                profileURL: url,
                fanTeam: fanTeam
            ),
            introduction: response.memberIntro,
            ghostCount: response.memberGhost,
            lckYears: response.memberLCKYears,
            userLevel: response.memberLevel
        )
    }
}
