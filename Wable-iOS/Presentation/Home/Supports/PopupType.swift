//
//  PopupType.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/16/25.
//

import Foundation

enum PopupViewType {
    case delete
    case report
    case ghost
    case ban

    var title: String {
        switch self {
        case .delete: return StringLiterals.Home.deletePopupTitle
        case .report: return StringLiterals.Home.reportPopupTitle
        case .ghost: return StringLiterals.Home.ghostPopupTitle
        case .ban: return "밴하기 ㅋㅋ"
        }
    }

    var content: String {
        switch self {
        case .delete: return StringLiterals.Home.deletePopupContent
        case .report: return StringLiterals.Home.reportPopupContent
        case .ghost: return ""
        case .ban: return "너이놈밴머거랏!!!"
        }
    }

    var leftButtonTitle: String {
        switch self {
        case .delete: return StringLiterals.Home.deletePopupUndo
        case .report: return StringLiterals.Home.reportPopupUndo
        case .ghost: return StringLiterals.Home.ghostPopupUndo
        case .ban: return "함봐줌"
        }
    }

    var rightButtonTitle: String {
        switch self {
        case .delete: return StringLiterals.Home.deletePopupDo
        case .report: return StringLiterals.Home.reportPopupDo
        case .ghost: return StringLiterals.Home.ghostPopupDo
        case .ban: return "밴ㄱㄱ"
        }
    }
}
