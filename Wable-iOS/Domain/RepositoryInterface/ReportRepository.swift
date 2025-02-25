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
    func createBan(memberID: Int, triggerType: BanTriggerType, triggerID: Int) -> AnyPublisher<Void, WableError>
}
