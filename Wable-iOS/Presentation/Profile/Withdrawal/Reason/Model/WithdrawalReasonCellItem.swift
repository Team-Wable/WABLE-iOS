//
//  WithdrawalReasonCellItem.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Foundation

struct WithdrawalReasonCellItem: Hashable {
    let reason: WithdrawalReason
    var isSelected: Bool = false
}
