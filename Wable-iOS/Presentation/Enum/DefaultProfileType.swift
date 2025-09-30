//
//  DefaultProfileType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import UIKit

enum DefaultProfileType: String, CaseIterable {
    case green = "img_profile_green"
    case blue = "img_profile_blue"
    case purple = "img_profile_purple"

    var uppercased: String {
        switch self {
        case .green:
            return "GREEN"
        case .blue:
            return "BLUE"
        case .purple:
            return "PURPLE"
        }
    }

    var image: UIImage? {
        switch self {
        case .green:
            return .imgProfileGreen
        case .blue:
            return .imgProfileBlue
        case .purple:
            return .imgProfilePurple
        }
    }
}

// MARK: - Helper

extension DefaultProfileType {
    static func random() -> DefaultProfileType {
        return allCases.randomElement() ?? .blue
    }

    static func from(uppercased: String) -> DefaultProfileType? {
        switch uppercased {
        case "GREEN":
            return .green
        case "BLUE":
            return .blue
        case "PURPLE":
            return .purple
        default:
            return nil
        }
    }
}
