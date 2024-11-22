//
//  TeamImageMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/22/24.
//

import UIKit

enum TeamImageMapper: String {
    case t1 = "T1"
    case gen = "GEN"
    case hle = "HLE"
    case dk = "DK"
    case kt = "KT"
    case fox = "FOX"
    case kdf = "KDF"
    case ns = "NS"
    case drx = "DRX"
    case bro = "BRO"
    
    var image: UIImage {
        switch self {
        case .t1:
            return ImageLiterals.Team.T1
        case .gen:
            return ImageLiterals.Team.Gen
        case .hle:
            return ImageLiterals.Team.Hle
        case .dk:
            return ImageLiterals.Team.Dk
        case .kt:
            return ImageLiterals.Team.Kt
        case .fox:
            return ImageLiterals.Team.Fox
        case .kdf:
            return ImageLiterals.Team.Kdf
        case .ns:
            return ImageLiterals.Team.Ns
        case .drx:
            return ImageLiterals.Team.Drx
        case .bro:
            return ImageLiterals.Team.Bro
        }
    }
}
