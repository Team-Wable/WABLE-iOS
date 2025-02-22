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
    func fetchUserInfo() -> AnyPublisher<AccountInfo, any Error> {
        return provider.request(
            .fetchUserInfo,
            for: DTO.Response.FetchAccountInfo.self
        )
        .map { info in
            ProfileMapper.accountInfoMapper(info)
        }
        .normalizeError()
    }
    
    func fetchUserProfile(memberID: Int) -> AnyPublisher<UserProfile, any Error> {
        provider.request(
            .fetchUserProfile(memberID: memberID),
            for: DTO.Response.FetchUserProfile.self
        )
        .map { profile in
            ProfileMapper.userProfileMapper(profile)
        }
        .normalizeError()
    }
    
    func updateUserProfile(profile: UserProfile, isPushAlarmAllowed: Bool) -> AnyPublisher<Void, any Error> {
        return provider.requestPublisher(
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
            )
        )
        .asVoidWithError()
    }
}
