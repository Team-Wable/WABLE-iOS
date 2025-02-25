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
                participantsCount: content.communityNum
            )
        }
    }
}


