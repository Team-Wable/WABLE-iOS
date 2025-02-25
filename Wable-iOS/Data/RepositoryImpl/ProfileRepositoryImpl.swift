//
//  ProfileRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/19/25.
//

import Combine
import Foundation

import CombineMoya
import Moya

final class ProfileRepositoryImpl {
    private let provider = APIProvider<ProfileTargetType>()
}

extension ProfileRepositoryImpl: ProfileRepository {
    func fetchUserInfo() -> AnyPublisher<AccountInfo, WableError> {
        return provider.request(
            .fetchUserInfo,
            for: DTO.Response.FetchAccountInfo.self
        )
        .map(ProfileMapper.toDomain)
        .mapWableError()
    }
    
    func fetchUserProfile(memberID: Int) -> AnyPublisher<UserProfile, WableError> {
        provider.request(
            .fetchUserProfile(memberID: memberID),
            for: DTO.Response.FetchUserProfile.self
        )
        .map(ProfileMapper.toDomain)
        .mapWableError()
    }
    
    func updateUserProfile(profile: UserProfile, isPushAlarmAllowed: Bool) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .updateUserProfile(
                request: DTO.Request.UpdateUserProfile(
                    info: DTO.Request.ProfileInfo(
                        nickname: profile.user.nickname,
                        memberIntro: profile.introduction,
                        isPushAlarmAllowed: isPushAlarmAllowed,
                        fcmToken: nil,
                        memberLCKYears: profile.lckYears,
                        memberFanTeam: profile.user.fanTeam?.rawValue,
                        memberDefaultProfileImage: profile.user.profileURL?.absoluteString
                    ),
                    file: nil
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
}
