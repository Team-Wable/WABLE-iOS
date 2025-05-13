//
//  AccountInfoCellItem.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Foundation

struct AccountInfoCellItem: Hashable {
    let title: String
    let description: String
    let isUserInteractive: Bool
    
    init(title: String, description: String, isUserInteractive: Bool = false) {
        self.title = title
        self.description = description
        self.isUserInteractive = isUserInteractive
    }
}
