//
//  WableSheetAction.swift
//  Wable-iOS
//
//  Created by 김진웅 on 6/22/25.
//

import Foundation

struct WableSheetAction {
    enum Style {
        case primary
        case gray
    }
    
    let title: String
    let style: Style
    let handler: (() -> Void)?
    
    init(
        title: String,
        style: Style,
        handler: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension WableSheetAction.Style {
    var buttonStyle: WableButton.Style {
        switch self {
        case .primary:
            return .primary
        case .gray:
            return .gray
        }
    }
}
