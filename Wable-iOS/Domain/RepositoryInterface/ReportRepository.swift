//
//  ReportRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

protocol ReportRepository {
    func createReport(nickname: String, text: String) -> AnyPublisher<Void, WableError>
    func createReport(nickname: String, text: String) async throws
    func createBan(memberID: Int, triggerType: TriggerType.Ban, triggerID: Int) -> AnyPublisher<Void, WableError>
    func createBan(memberID: Int, triggerType: TriggerType.Ban, triggerID: Int) async throws
}
