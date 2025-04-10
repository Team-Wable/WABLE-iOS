//
//  CommunityMapper.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Foundation

enum CommunityMapper { }

extension CommunityMapper {
    static func toDomain(_ response: [DTO.Response.FetchCommunites]) -> [Community] {
        return response.map { content in
            let name = LCKTeam(rawValue: content.communityName)
            
            return Community(
                name: name,
                registrationRate: content.registrationRate
            )
        }
    }
    
    static func toDomain(_ response: DTO.Response.IsUserRegistered) -> CommunityRegistrationStatus {
        guard let teamName = response.commnunityName else {
            return CommunityRegistrationStatus(team: nil, isRegistered: false)
        }
        
        return CommunityRegistrationStatus(team: LCKTeam(rawValue: teamName), isRegistered: true)
    }
}
