//
//  ProfileRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/19/25.
//

import Combine
import Foundation
import UIKit

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
    
    func updateUserProfile(
        profile: UserProfile? = nil,
        isPushAlarmAllowed: Bool? = nil,
        isAlarmAllowed: Bool? = nil,
        image: UIImage? = nil,
        fcmToken: String? = nil,
        defaultProfileType: String? = nil
    ) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .updateUserProfile(
                request: DTO.Request.UpdateUserProfile(
                    info: DTO.Request.ProfileInfo(
                        nickname: profile?.user.nickname,
                        isAlarmAllowed: isAlarmAllowed,
                        memberIntro: profile?.introduction,
                        isPushAlarmAllowed: isPushAlarmAllowed,
                        fcmToken: fcmToken,
                        memberLCKYears: profile?.lckYears,
                        memberFanTeam: profile?.user.fanTeam?.rawValue,
                        memberDefaultProfileImage: defaultProfileType
                    ),
                    file: image?.jpegData(compressionQuality: 0.1)
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
}
