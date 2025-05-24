//
//  ReportRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class ReportRepositoryImpl {
    private let provider = APIProvider<ReportTargetType>()
}

extension ReportRepositoryImpl: ReportRepository {
    func createReport(nickname: String, text: String) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createReport(
                request: DTO.Request.CreateReport(
                    reportTargetNickname: nickname,
                    relateText: text
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func createReport(nickname: String, text: String) async throws {
        do {
            _ = try await provider.request(
                .createReport(
                    request: DTO.Request.CreateReport(
                        reportTargetNickname: nickname,
                        relateText: text
                    )
                ),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func createBan(memberID: Int, triggerType: TriggerType.Ban, triggerID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createBan(
                request: DTO.Request.CreateBan(
                    memberID: memberID,
                    triggerType: triggerType.rawValue,
                    triggerID: triggerID
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func createBan(memberID: Int, triggerType: TriggerType.Ban, triggerID: Int) async throws {
        do {
            _ = try await provider.request(
                .createBan(
                    request: DTO.Request.CreateBan(
                        memberID: memberID,
                        triggerType: triggerType.rawValue,
                        triggerID: triggerID
                    )
                ),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
}

// MARK: - Mock

struct MockReportRepository: ReportRepository {
    private var delaySeconds: TimeInterval { return .random(in: 1...3) }
    
    func createReport(nickname: String, text: String) -> AnyPublisher<Void, WableError> {
        return .just(())
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func createReport(nickname: String, text: String) async throws {
        
    }
    
    func createBan(memberID: Int, triggerType: TriggerType.Ban, triggerID: Int) -> AnyPublisher<Void, WableError> {
        return .just(())
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func createBan(memberID: Int, triggerType: TriggerType.Ban, triggerID: Int) async throws {
        
    }
}
