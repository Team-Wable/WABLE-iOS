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
    
    enum MyPage {
        static let profileIntroduction = "T1을(를) 응원하고 있어요.\n2022년부터 LCK를 보기 시작했어요."
        static let transparencyTitle = "투명도"
        static let badgeTitle = "뱃지"
        static let myPageCustomerURL = "https://joyous-ghost-8c7.notion.site/Don-t-be-e949f7751de94ba682f4bd6792cbe36e"
        static let myPageFeedbackURL = "https://forms.gle/DqnypURRBDks7WqJ6"
        static let myPageUseTermURL = "https://joyous-ghost-8c7.notion.site/4ac9966cf7d944bf9595352edbc1b1b0"
        
        static let myPageEditProfileTitle = "와블에서 멋진 모습으로\n활동해 보세요!"
        static let myPageProfilePlaceholder = "예) 중꺾마"
        static let myPageProfileCheckButtonTitle = "중복확인"
        static let myPageProfileNicknameInfo = "10자리 이내, 문자/숫자로 입력 가능해요"
        static let myPageProfileNicknameNotInclude = "닉네임에 사용할 수 없는 문자가 포함되어 있어요."
        static let myPageProfileNicknameAlreadyUsed = "이미 사용 중인 닉네임입니다."
        static let myPageProfileNicknameAvailable = "사용 가능한 닉네임입니다."
        static let myPageCompleteButtonTitle = "완료"
        
        static let myPageMoreInfoTitle = "이용약관"
        static let myPageMoreInfoButtonTitle = "자세히 보기"
        static let myPageSignOutButtonTitle = "계정삭제"
        static let myPageLogoutPopupTitleLabel = "로그아웃"
        static let myPageLogoutPopupContentLabel = "계정에서 로그아웃하시겠어요?"
        static let myPageLogoutPopupLeftButtonTitle = "취소"
        static let myPageLogoutPopupRightButtonTitle = "확인"
        static let myPageSignOutPopupTitleLabel = "계정삭제"
        static let myPageSignOutPopupContentLabel = "계정을 삭제하시겠어요?"
        static let myPageSignOutPopupLeftButtonTitle = "취소"
        static let myPageSignOutPopupRightButtonTitle = "확인"
        
        static let myPageSignOutReason1 = "온화하지 못한 내용이 많이 보여요"
        static let myPageSignOutReason2 = "원하는 콘텐츠가 없어요"
        static let myPageSignOutReason3 = "필요한 커뮤니티 기능이 없어요"
        static let myPageSignOutReason4 = "자주 사용하지 않아요"
        static let myPageSignOutReason5 = "앱 오류가 있어 사용하기 불편해요"
        static let myPageSignOutReason6 = "가입할 때 사용한 소셜 계정이 바뀔 예정이에요"
        static let myPageSignOutReason7 = "기타"
        static let myPageSignOutContinueButtonTitle = "계속"
        
        static let myPageSignOutConfirmTitle = "계정을 삭제하기 전에\n아래 내용을 꼭 확인해 주세요"
        static let myPageSignOutConfirmInfo1 = "계정 삭제 처리된 이메일 아이디는 재가입 방지를 위해 30일간 보존된 후 삭제 처리됩니다."
        static let myPageSignOutConfirmInfo2 = "탈퇴와 재가입을 통해 아이디를 교체하며 선량한 이용자들께 피해를 끼치는 행위를 방지하려는 조치 오니 넓은 양해 부탁드립니다."
        static let myPageSignOutConfirmInfo3 = "안내사항을 모두 확인하였으며, 이에 동의합니다."
        static let myPageSignOutConfirmButtonTitle = "계속"
        
        static let myPageSignOutTitle = "정말 떠나시는 건가요?"
        static let myPageSignOutSubTitle = "계정을 삭제하시려는 이유를 말씀해 주세요\n서비스 개선에 중요한 자료로 활용하겠습니다"
    }
    
    enum BottomSheet {
        static let accountInfo = "계정 정보"
        static let settingAlarm = "알림 설정"
        static let feedback = "피드백 남기기"
        static let customerCenter = "고객센터"
        static let logout = "로그아웃"
    }
    
    enum Network {
        static let expired = "access, refreshToken 모두 만료되었습니다. 재로그인이 필요합니다."
        static let baseImageURL = "https://github.com/TeamDon-tBe/SERVER/assets/97835512/fb3ea04c-661e-4221-a837-854d66cdb77e"
        static let notificationImageURL = "https://github.com/TeamDon-tBe/SERVER/assets/128011308/327d416e-ef1f-4c10-961d-4d9b85632d87"
        static let warnUserGoogleFormURL = "https://forms.gle/FTgZKkajwtzFvAk99"
        static let errorMessage = "이런!\n현재 요청하신 페이지를 찾을 수 없어요!"
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
}
