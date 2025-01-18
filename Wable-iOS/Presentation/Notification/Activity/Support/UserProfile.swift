//
//  UserProfile.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 9/4/24.
//

import UIKit

enum UserProfile: String {
    case purple = "PURPLE"
    case green = "GREEN"
    case blue = "BLUE"
    
    var image: UIImage {
        switch self {
        case .purple:
            return ImageLiterals.Image.imgProfile1
        case .green:
            return ImageLiterals.Image.imgProfile3
        case .blue:
            return ImageLiterals.Image.imgProfile2
        }
    }
}
