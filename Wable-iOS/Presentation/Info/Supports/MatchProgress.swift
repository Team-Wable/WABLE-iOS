//
//  MatchProgress.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

enum MatchProgress: String {
    case scheduled = "SCHEDULED"
    case progress = "PROGRESS"
    case termination = "TERMINATION"
    
    var image: UIImage? {
        switch self {
        case .scheduled:
            return ImageLiterals.Tag.tagTodo
        case .progress:
            return ImageLiterals.Tag.tagProgress
        case .termination:
            return ImageLiterals.Tag.tagEnd
        }
    }
    
    init?(from rawValue: String) {
        self.init(rawValue: rawValue.uppercased())
    }
}
