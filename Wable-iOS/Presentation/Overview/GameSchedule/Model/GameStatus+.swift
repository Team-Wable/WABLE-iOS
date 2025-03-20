//
//  GameStatus+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import UIKit

extension GameStatus {
    var image: UIImage {
        switch self {
        case .scheduled:
            return .tagTodo
        case .progress:
            return .tagProgress
        case .termination:
            return .tagEnd
        }
    }
}
