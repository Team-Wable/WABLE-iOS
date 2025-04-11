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
                team: name,
                registrationRate: content.registrationRate
            )
        }
    }
    
    static func toDomain(_ response: DTO.Response.IsUserRegistered) -> CommunityRegistration {
        guard let teamName = response.commnunityName else {
            return CommunityRegistration(team: nil, hasRegisteredTeam: false)
        }
        
        return CommunityRegistration(team: LCKTeam(rawValue: teamName), hasRegisteredTeam: true)
    }
}
