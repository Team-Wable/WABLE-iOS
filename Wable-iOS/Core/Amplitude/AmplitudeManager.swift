//
//  AmplitudeManager.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Foundation

import AmplitudeSwift

final class AmplitudeManager {
    static let shared = AmplitudeManager()
    
    private let amplitude: Amplitude
    
    private init() {
        amplitude = Amplitude(configuration: Configuration(apiKey: Bundle.amplitudeAppKey))
    }
    
    func trackEvent(tag: EventTag) {
        amplitude.track(eventType: tag.value)
    }
}

extension AmplitudeManager {
    
    // MARK: - EventTag

    enum EventTag: CaseIterable {
        case clickCommunityBotnavi
        case clickViewitBotnavi
        case clickHomeBotnavi
        case clickNewsBotnavi
        case clickNotiBotnavi
        case clickMyprofileBotnavi
        case clickLikePost
        case clickGhostPost
        case clickWritePost
        case clickDeletePost
        case clickWithdrawghostPopup
        case clickApplyghostPopup
        case clickUploadLinkpost
        case clickViralinkTeamzone
        case clickApplyTeamzone
        case clickUploadComment
        case clickWriteComment
        case clickWriteRecomment
        case clickLikeComment
        case clickGhostComment
        case clickNews
        case clickAnnouncement
        case clickGameschedule
        case clickRanking
        case clickActivitiesnoti
        case clickInfonoti
        case clickSigninKakao
        case clickSigninApple
        case clickAgreePopupSignup
        case clickNextYearSignup
        case clickDetourTeamSignup
        case clickNextTeamSignup
        case clickChangePictureProfileSignup
        case clickAddPictureProfileSignup
        case clickNextProfileSignup
        case clickCompleteTncSignup
        case clickJoinPopupSignup
        case clickUploadPost
        case clickAttachPhoto
        case clickWriteFirstpost
        case clickCompleteLogout
        case clickDeleteAccount
        case clickNextDeletereason
        case clickNextDeleteguide
        case clickDoneDeleteaccount
        case clickGobackHome
        case clickDownloadPhoto
        
        var value: String {
            switch self {
            case .clickCommunityBotnavi: return "click_community_botnavi"
            case .clickViewitBotnavi: return "click_viewit_botnavi"
            case .clickHomeBotnavi: return "click_home_botnavi"
            case .clickNewsBotnavi: return "click_news_botnavi"
            case .clickNotiBotnavi: return "click_noti_botnavi"
            case .clickMyprofileBotnavi: return "click_myprofile_botnavi"
            case .clickLikePost: return "click_like_post"
            case .clickGhostPost: return "click_ghost_post"
            case .clickWritePost: return "click_write_post"
            case .clickDeletePost: return "click_delete_post"
            case .clickWithdrawghostPopup: return "click_withdrawghost_popup"
            case .clickApplyghostPopup: return "click_applyghost_popup"
            case .clickUploadLinkpost: return "click_upload_linkpost"
            case .clickViralinkTeamzone: return "click_virallink_teamzone"
            case .clickApplyTeamzone: return "click_apply_teamzone"
            case .clickUploadComment: return "click_upload_comment"
            case .clickWriteComment: return "click_write_comment"
            case .clickWriteRecomment: return "click_write_recomment"
            case .clickLikeComment: return "click_like_comment"
            case .clickGhostComment: return "click_ghost_comment"
            case .clickNews: return "click_news"
            case .clickAnnouncement: return "click_announcement"
            case .clickGameschedule: return "click_gameschedule"
            case .clickRanking: return "click_ranking"
            case .clickActivitiesnoti: return "click_activitiesnoti"
            case .clickInfonoti: return "click_infonoti"
            case .clickSigninKakao: return "click_signin_kakao"
            case .clickSigninApple: return "click_signin_apple"
            case .clickAgreePopupSignup: return "click_agree_popup_signup"
            case .clickNextYearSignup: return "click_next_year_signup"
            case .clickDetourTeamSignup: return "click_detour_team_signup"
            case .clickNextTeamSignup: return "click_next_team_signup"
            case .clickChangePictureProfileSignup: return "click_change_picture_profile_signup"
            case .clickAddPictureProfileSignup: return "click_add_picture_profile_signup"
            case .clickNextProfileSignup: return "click_next_profile_signup"
            case .clickCompleteTncSignup: return "click_complete_tnc_signup"
            case .clickJoinPopupSignup: return "click_join_popup_signup"
            case .clickUploadPost: return "click_upload_post"
            case .clickAttachPhoto: return "click_attach_photo"
            case .clickWriteFirstpost: return "click_write_firstpost"
            case .clickCompleteLogout: return "click_complete_logout"
            case .clickDeleteAccount: return "click_delete_account"
            case .clickNextDeletereason: return "click_next_deletereason"
            case .clickNextDeleteguide: return "click_next_deleteguide"
            case .clickDoneDeleteaccount: return "click_done_deleteaccount"
            case .clickGobackHome: return "click_goback_home"
            case .clickDownloadPhoto: return "click_download_photo"
            }
        }
    }
}
