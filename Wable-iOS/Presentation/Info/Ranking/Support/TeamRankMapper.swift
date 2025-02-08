//
//  TeamRankMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/22/24.
//

import UIKit

enum TeamRankMapper: String {
    case t1 = "T1"
    case gen = "GEN"
    case hle = "HLE"
    case dk = "DK"
    case kt = "KT"
    case bfx = "BFX"
    case dnf = "DNF"
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
        case .bfx:
            return ImageLiterals.Team.BFX
        case .dnf:
            return ImageLiterals.Team.DNF
        case .ns:
            return ImageLiterals.Team.Ns
        case .drx:
            return ImageLiterals.Team.Drx
        case .bro:
            return ImageLiterals.Team.Bro
        }
    }
    
    var lckCupTeam: LCKCupTeam {
        switch self {
        case .t1, .hle, .dnf, .bro, .bfx:
            return .baron
        case .gen, .dk, .ns, .drx, .kt:
            return .elder
        }
    }
}

extension TeamRankMapper {
    enum LCKCupTeam {
        case baron
        case elder
        
        var color: UIColor {
            switch self {
            case .baron:
                return .purple50
            case .elder:
                return .sky50
            }
        }
    }
}
