//
//  DefaultProfileType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import Foundation

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
}
