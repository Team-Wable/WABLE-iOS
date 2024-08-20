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
    case DX = "DX"
    case KT = "KT"
    case FOX = "FOX"
    case NS = "NS"
    case KDF = "KDF"
    case HLE = "HLE"
    
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
        case .DX:
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

        }
    }
}
