//
//  Array+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 11/29/24.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
