//
//  ImageLiterals.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import UIKit

enum ImageLiterals {
    enum Button {
        static var btnApple: UIImage { .load(name: "btn_apple") }
        static var btnCheckboxActive: UIImage { .load(name: "btn_checkbox_active") }
        static var btnCheckboxDefault: UIImage { .load(name: "btn_checkbox_default") }
        static var btnCheckboxVariant: UIImage { .load(name: "btn_checkbox_variant") }
        static var btnDropdownDown: UIImage { .load(name: "btn_dropdown_down") }
        static var btnDropdownUp: UIImage { .load(name: "btn_dropdown_up") }
        static var btnGhostDefaultLarge: UIImage { .load(name: "btn_ghost_default_large") }
        static var btnGhostDefaultSmall: UIImage { .load(name: "btn_ghost_default_small") }
        static var btnGhostDisabledLarge: UIImage { .load(name: "btn_ghost_disabled_large") }
        static var btnGhostDisabledSmall: UIImage { .load(name: "btn_ghost_disabled_small") }
        static var btnKakao: UIImage { .load(name: "btn_kakao") }
        static var btnNext: UIImage { .load(name: "btn_next") }
        static var btnRippleDefault: UIImage { .load(name: "btn_ripple_default") }
        static var btnRipplePress: UIImage { .load(name: "btn_ripple_press") }
        static var btnWrite: UIImage { .load(name: "btn_write") }
    }
    
    enum Icon {
        static var icBack: UIImage { .load(name: "ic_back") }
        static var icChange: UIImage { .load(name: "ic_change") }
        static var icDelete: UIImage { .load(name: "ic_delete") }
        static var icEdit: UIImage { .load(name: "ic_edit") }
        static var icGhostDefault: UIImage { .load(name: "ic_ghost_default") }
        static var icGhostDisabled: UIImage { .load(name: "ic_ghost_disabled") }
        static var icHeartDefault: UIImage { .load(name: "ic_heart_default") }
        static var icHeartPress: UIImage { .load(name: "ic_heart_press") }
        static var icHomeDefault: UIImage { .load(name: "ic_home_default") }
        static var icHomePress: UIImage { .load(name: "ic_home_press") }
        static var icInfoDefault: UIImage { .load(name: "ic_info_default") }
        static var icInfoPress: UIImage { .load(name: "ic_info_press") }
        static var icMeatball: UIImage { .load(name: "ic_meatball") }
        static var icMyDefault: UIImage { .load(name: "ic_my_default") }
        static var icMyPress: UIImage { .load(name: "ic_my_press") }
        static var icNotiBadge: UIImage { .load(name: "ic_noti_badge") }
        static var icNotiDefault: UIImage { .load(name: "ic_noti_default") }
        static var icNotiPress: UIImage { .load(name: "ic_noti_press") }
        static var icPhoto: UIImage { .load(name: "ic_photo") }
        static var icPlus: UIImage { .load(name: "ic_plus") }
        static var icProfileplus: UIImage { .load(name: "ic_profileplus") }
        static var icReport: UIImage { .load(name: "ic_report") }
        static var icRipple: UIImage { .load(name: "ic_ripple") }
        static var icX: UIImage { .load(name: "ic_x") }
    }
    
    enum Image {
        static var imgProfileLarge: UIImage { .load(name: "img_profile_large") }
        static var imgProfileMedium: UIImage { .load(name: "img_profile_medium") }
        static var imgProfileSmall: UIImage { .load(name: "img_profile_small") }
        static var imgProfileXsmall: UIImage { .load(name: "img_profile_xsmall") }
    }
    
    enum Logo {
        static var logoSymbolLarge: UIImage { .load(name: "logo_symbol_large") }
        static var logoSymbolSmall: UIImage { .load(name: "logo_symbol_small") }
        static var logoType: UIImage { .load(name: "logo_type") }
    }
    
    enum Toast {
        static var toastProgress: UIImage { .load(name: "toast_progress") }
        static var toastStatus: UIImage { .load(name: "toast_status") }
        static var toastSuccess: UIImage { .load(name: "toast_success") }
        static var toastWarning: UIImage { .load(name: "toast_warning") }
    }
    
    enum Tag {
        static var tagBro: UIImage { .load(name: "tag_Bro") }
        static var tagDk: UIImage { .load(name: "tag_Dk") }
        static var tagDrx: UIImage { .load(name: "tag_Drx") }
        static var tagFox: UIImage { .load(name: "tag_Fox") }
        static var tagGen: UIImage { .load(name: "tag_Gen") }
        static var tagHle: UIImage { .load(name: "tag_Hle") }
        static var tagKdf: UIImage { .load(name: "tag_Kdf") }
        static var tagKt: UIImage { .load(name: "tag_Kt") }
        static var tagNs: UIImage { .load(name: "tag_Ns") }
        static var tagT1: UIImage { .load(name: "tag_T1") }
        static var tagEnd: UIImage { .load(name: "tag_end") }
        static var tagProgress: UIImage { .load(name: "tag_progress") }
        static var tagTodo: UIImage { .load(name: "tag_todo") }

    }
}

extension UIImage {
    static func load(name: String) -> UIImage {
        guard let image = UIImage(named: name, in: nil, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = name
        return image
    }
}
