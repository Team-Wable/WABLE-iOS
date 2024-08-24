//
//  StringLiterals.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import UIKit

enum StringLiterals {
    enum TabBar {
        static let home = "홈"
        static let info = "소식"
        static let noti = "알림"
        static let my = "마이"

    }
    
    enum Login {
        static let loginTitle = "클린 LCK 팬 커뮤니티\n와블에서 함께 해요"
    }
    
    enum Join {
        static let JoinLCKYearTitle = "언제부터 LCK를 시청하셨나요?"
        static let JoinLCKYearSubTitle = "꼭 LCK가 아닌 LOL경기여도 좋아요"
        static let JoinLCKYearStartYear = "시청 시작 연도"
        static let JoinLCKYearDefaultYear = "2024"
        
        static let JoinLCKTeamTitle = "가장 응원하는 팀을 골라주세요"
        static let JoinLCKTeamSubTitle = "선택하신 팀은 프로필에 응원중인 팀으로 소개돼요\n팀 순서는 랜덤으로 표시됩니다"
        static let JoinLCKTeamNoneButtonTitle = "아직 응원하는 팀이 없어요"
        
        static let JoinProfileTitle = "와블에서 활동할\n프로필을 등록해 주세요"
        static let JoinProfileSubTitle = "프로필 사진은 나중에도 등록 가능해요"
        static let JoinProfilePlaceholder = "예) 중꺾마"
        static let JoinProfileCheckButtonTitle = "중복확인"
        static let JoinProfileNicknameInfo = "10자리 이내, 문자/숫자로 입력 가능해요"
        static let JoinProfileNicknameNotInclude = "닉네임에 사용할 수 없는 문자가 포함되어 있어요."
        static let JoinProfileNicknameAlreadyUsed = "이미 사용 중인 닉네임입니다."
        static let JoinProfileNicknameAvailable = "사용 가능한 닉네임입니다."
        
        static let JoinAgreementTitle = "와블 이용을 위해\n동의가 필요해요"
        static let JoinAgreementAllCheck = "전체 선택"
        static let useAgreement = "[필수] 이용약관 동의"
        static let privacyAgreement = "[필수] 개인정보 수집 및 이용동의"
        static let checkAge = "[필수] 만 14세 이상입니다"
        static let advertisementAgreement = "마케팅 활용/광고성 정보 수신동의"
        static let JoinAgreementMoreButtonTitle = "보러가기"
        
        static let JoinNextButtonTitle = "다음으로"
        static let JoinCompleteButtonTitle = "완료"
    }
    
    enum Notification {
        static let notificationNavigationTitle = "알림"
    }
    
    enum Camera {
        static let photoNoAuth = "Don't Be 앱에 사진 권한이 없습니다.\n설정으로 이동하여 권한 설정을 해주세요."
    }
    
    enum VersionUpdate {
        static let versionTitle = "v 1.0.1 업데이트 안내\n와블이 업데이트 되었습니다."
        static let versionMessage = "•푸쉬 알림 기능이 추가되었어요.\n•그 외 자잘한 오류들을 해결했어요."
    }
    
    enum Home {
        static let ghostPopupTitle = "와블의 온화한 문화를 해치는\n누군가를 발견하신 건가요?"
        static let ghostPopupUndo = "고민할게요"
        static let ghostPopupDo = "네 맞아요"
        static let placeholder = "에게 댓글 남기기..."
    }
    
    enum Info {
        static let lckSummer = "2024 LCK Summer"
        static let today = "TODAY "
    }
    
    enum Endpoint {
        enum Home {
            static let getContent = "api/v2/contents"
        }
    }
}
