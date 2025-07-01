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
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
}

extension ProfileRepositoryImpl: ProfileRepository {
    func updateUserProfile(nickname: String, fcmToken: String?) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .updateUserProfile(
                request: DTO.Request.UpdateUserProfile(
                    info: DTO.Request.ProfileInfo(
                        nickname: nickname,
                        isAlarmAllowed: nil,
                        memberIntro: nil,
                        isPushAlarmAllowed: nil,
                        fcmToken: fcmToken,
                        memberLCKYears: nil,
                        memberFanTeam: nil,
                        memberDefaultProfileImage: nil
                    ),
                    file: nil
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func fetchFCMToken() -> String? {
        do {
            return try tokenStorage.load(.fcmToken)
        } catch {
            return nil
        }
    }
    
    func updateFCMToken(token: String) {
        do {
            try tokenStorage.save(token, for: .fcmToken)
            WableLogger.log("FCM 토큰 업데이트 성공", for: .debug)
        } catch {
            WableLogger.log("FCM 토큰 업데이트에 실패했습니다.", for: .error)
        }
    }
    
    func fetchAccountInfo() async throws -> AccountInfo {
        do {
            let response = try await provider.request(.fetchUserInfo, for: DTO.Response.FetchAccountInfo.self)
            return ProfileMapper.toDomain(response)
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func fetchUserProfile(memberID: Int) -> AnyPublisher<UserProfile, WableError> {
        provider.request(
            .fetchUserProfile(memberID: memberID),
            for: DTO.Response.FetchUserProfile.self
        )
        .map(ProfileMapper.toDomain)
        .mapWableError()
    }
    
    func fetchUserProfile(memberID: Int) async throws -> UserProfile {
        do {
            let response = try await provider.request(
                .fetchUserProfile(memberID: memberID),
                for: DTO.Response.FetchUserProfile.self
            )
            return ProfileMapper.toDomain(response)
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func updateUserProfile(
        profile: UserProfile?,
        isPushAlarmAllowed: Bool?,
        isAlarmAllowed: Bool?,
        image: UIImage?,
        fcmToken: String?,
        defaultProfileType: String?
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
