//
//  GhostRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

protocol GhostRepository {
    func postGhostReduction(
        alarmTriggerType: String,
        alarmTriggerID: Int,
        targetMemberID: Int,
        reason: String
    ) -> AnyPublisher<Void, WableError>
    
    func postGhostReduction(
        alarmTriggerType: String,
        alarmTriggerID: Int,
        targetMemberID: Int,
        reason: String
    ) async throws
}
