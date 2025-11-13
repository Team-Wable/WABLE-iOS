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
        let createdDate = DateFormatterHelper.date(from: response.joinDate, type: .dotSeparatedDate)
        let splitKeyword = response.socialPlatform.split(separator: " ").map { "\($0)" }.first
        let socialPlatform = SocialPlatform(rawValue: splitKeyword ?? response.socialPlatform)
        
        return AccountInfo(
            memberID: response.memberID,
            createdDate: createdDate,
            displayMemberID: response.showMemberID ?? "",
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
