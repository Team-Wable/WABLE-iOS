//
//  UIButton+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

extension UIButton {
    func setTitleWithConfiguration(_ title: String, font: UIFont, textColor: UIColor) {
        
        var config = self.configuration ?? UIButton.Configuration.plain()
        
        config.title = title
        config.imagePadding = 4.adjusted
        
        var titleAttributes = AttributeContainer()
        titleAttributes.font = font
        titleAttributes.foregroundColor = textColor
        
        config.attributedTitle = AttributedString(title, attributes: titleAttributes)
        
        self.configuration = config
    }
}
