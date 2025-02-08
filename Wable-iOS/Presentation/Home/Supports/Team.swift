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
    case DK = "DK"
    case KT = "KT"
    case BFX = "BFX"
    case NS = "NS"
    case DNF = "DNF"
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
        case .BFX:
            return ImageLiterals.Tag.tagFox
        case .NS:
            return ImageLiterals.Tag.tagNs
        case .DNF:
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
        case .BFX:
            return ImageLiterals.Team.BFX
        case .NS:
            return ImageLiterals.Team.Ns
        case .DNF:
            return ImageLiterals.Team.DNF
        case .HLE:
            return ImageLiterals.Team.Hle
        case .TBD:
            return ImageLiterals.Team.TBD
        }
    }
}
