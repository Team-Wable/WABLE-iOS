//
//  GhostRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

final class GhostRepositoryImpl: GhostRepository {
    private let provider: APIProvider<GhostTargetType>
    
    init(provider: APIProvider<GhostTargetType> = .init()) {
        self.provider = provider
    }
    
    func postGhostReduction(
        alarmTriggerType: String,
        alarmTriggerID: Int,
        targetMemberID: Int,
        reason: String
    ) -> AnyPublisher<Void, WableError> {
        let request = DTO.Request.UpdateGhost(
            alarmTriggerType: alarmTriggerType,
            targetMemberID: targetMemberID,
            alarmTriggerID: alarmTriggerID,
            ghostReason: reason
        )
        
        return provider.request(
            .ghostReduction(request: request),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
}
