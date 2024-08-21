//
//  Team.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

enum Team: String {
    case T1 = "T1"
    case GEN = "GEN"
    case BRO = "BRO"
    case DRX = "DRX"
    case DK = "DX"
    case KT = "KT"
    case FOX = "FOX"
    case NS = "NS"
    case KDF = "KDF"
    case HLE = "HLE"
    case TBD = "TBD"
    
    var tag: UIImage {
        switch self {
        case .T1:
            return ImageLiterals.Tag.tagT1
        case .GEN:
            return ImageLiterals.Tag.tagGen
        case .BRO:
            return ImageLiterals.Tag.tagBro
        case .DRX:
            return ImageLiterals.Tag.tagDrx
        case .DK:
            return ImageLiterals.Tag.tagDk
        case .KT:
            return ImageLiterals.Tag.tagKt
        case .FOX:
            return ImageLiterals.Tag.tagFox
        case .NS:
            return ImageLiterals.Tag.tagNs
        case .KDF:
            return ImageLiterals.Tag.tagKdf
        case .HLE:
            return ImageLiterals.Tag.tagHle
        case .TBD:
            return UIImage()
        }
    }
    
    var logo: UIImage {
        switch self {
        case .T1:
            return ImageLiterals.Team.T1
        case .GEN:
            return ImageLiterals.Team.Gen
        case .BRO:
            return ImageLiterals.Team.Bro
        case .DRX:
            return ImageLiterals.Team.Drx
        case .DK:
            return ImageLiterals.Team.Dk
        case .KT:
            return ImageLiterals.Team.Kt
        case .FOX:
            return ImageLiterals.Team.Fox
        case .NS:
            return ImageLiterals.Team.Ns
        case .KDF:
            return ImageLiterals.Team.Kdf
        case .HLE:
            return ImageLiterals.Team.Hle
        case .TBD:
            return ImageLiterals.Team.TBD
        }
    }
}
