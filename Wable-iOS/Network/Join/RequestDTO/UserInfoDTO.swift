//
//  UserInfoDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/8/25.
//

import Foundation

struct UserInfoDTO: Encodable {
    let nickname: String?
    let isAlarmAllowed: Bool?
    let memberIntro: String?
    let isPushAlarmAllowed: Bool?
    let fcmToken: String?
    let memberLckYears: Int?
    let memberFanTeam: String?
    let memberDefaultProfileImage: String?
    let file: Data?
}

// 프린트 찍어보려고 임시적으로 프로퍼티 Privateg 해제. 다시 고쳐주기
final class UserInfoBuilder {
    var nickname: String?
    var isAlarmAllowed: Bool?
    var memberIntro: String?
    var isPushAlarmAllowed: Bool?
    var fcmToken: String?
    var memberLckYears: Int?
    var memberFanTeam: String?
    var memberDefaultProfileImage: String?
    var file: Data?
    
    @discardableResult
    func setNickname(_ nickname: String?) -> Self {
        self.nickname = nickname
        return self
    }
    
    @discardableResult
    func setIsAlarmAllowed(_ isAlarmAllowed: Bool?) -> Self {
        self.isAlarmAllowed = isAlarmAllowed
        return self
    }
    
    @discardableResult
    func setMemberIntro(_ memberIntro: String?) -> Self {
        self.memberIntro = memberIntro
        return self
    }
    
    @discardableResult
    func setIsPushAlarmAllowed(_ isPushAlarmAllowed: Bool?) -> Self {
        self.isPushAlarmAllowed = isPushAlarmAllowed
        return self
    }
    
    @discardableResult
    func setFcmToken(_ fcmToken: String?) -> Self {
        self.fcmToken = fcmToken
        return self
    }
    
    @discardableResult
    func setMemberLckYears(_ memberLckYears: Int?) -> Self {
        self.memberLckYears = memberLckYears
        return self
    }
    
    @discardableResult
    func setMemberFanTeam(_ memberFanTeam: String?) -> Self {
        self.memberFanTeam = memberFanTeam
        return self
    }
    
    @discardableResult
    func setMemberDefaultProfileImage(_ memberDefaultProfileImage: String?) -> Self {
        self.memberDefaultProfileImage = memberDefaultProfileImage
        return self
    }
    
    @discardableResult
    func setFile(_ file: Data?) -> Self {
        self.file = file
        return self
    }
    
    @discardableResult
    func build() -> UserInfoDTO {
        return UserInfoDTO(
            nickname: nickname,
            isAlarmAllowed: isAlarmAllowed,
            memberIntro: memberIntro,
            isPushAlarmAllowed: isPushAlarmAllowed,
            fcmToken: fcmToken,
            memberLckYears: memberLckYears,
            memberFanTeam: memberFanTeam,
            memberDefaultProfileImage: memberDefaultProfileImage,
            file: file
        )
    }
}
