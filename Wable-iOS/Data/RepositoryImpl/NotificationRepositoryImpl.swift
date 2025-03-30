//
//  NotificationRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

final class NotificationRepositoryImpl: NotificationRepository {
    private let provider: APIProvider<NotificationTargetType>
    
    init(provider: APIProvider<NotificationTargetType> = .init()) {
        self.provider = provider
    }
    
    func fetchInfoNotifications(cursor: Int) -> AnyPublisher<[InfoNotification], WableError> {
        return provider.request(
            .fetchInfoNotifications(cursor: cursor),
            for: [DTO.Response.FetchInfoNotifications].self
        )
        .map(NotificationMapper.toDomain(_:))
        .mapWableError()
    }
    
    func checkNotification() -> AnyPublisher<Void, WableError> {
        return provider.request(
            .checkNotification,
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func fetchUserNotifications(cursor: Int) -> AnyPublisher<[ActivityNotification], WableError> {
        return provider.request(
            .fetchUserNotifications(cursor: cursor),
            for: [DTO.Response.FetchUserNotifications].self
        )
        .map(NotificationMapper.toDomain(_:))
        .mapWableError()
    }
    
    func fetchUncheckedNotificationNumber() -> AnyPublisher<Int, WableError> {
        return provider.request(
            .fetchUncheckedNotificationNumber,
            for: DTO.Response.FetchNotificationNumber.self
        )
        .map { $0.notificationNumber }
        .mapWableError()
    }
}

struct MockNotificationRepositoryImpl: NotificationRepository {
    func fetchInfoNotifications(cursor: Int) -> AnyPublisher<[InfoNotification], WableError> {
        let range: ClosedRange<Int>
        
        switch cursor {
        case -1:
            range = 1...15
        case 15:
            range = 16...30
        case 30:
            range = 31...33
        default:
            return .just([])
                .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        let types: [InfoNotificationType] = [.gameDone, .gameStart, .weekDone]
        return .just(range.map { id in
            InfoNotification(
                id: id,
                type: types.randomElement(),
                time: Calendar.current.date(byAdding: .day, value: -id, to: Date()),
                imageURL: URL(string: Constant.imageURLText)
            )
        })
        .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func checkNotification() -> AnyPublisher<Void, WableError> {
        return .just(())
        .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func fetchUncheckedNotificationNumber() -> AnyPublisher<Int, WableError> {
        return .fail(.anotherAccessToken)
    }
    
    func fetchUserNotifications(cursor: Int) -> AnyPublisher<[ActivityNotification], WableError> {
        return .fail(.anotherAccessToken)
    }
    
    private var randomDelaySecond: Double { .random(in: 0.3...1.0) }
    
    private enum Constant {
        static let imageURLText: String = "https://private-user-images.githubusercontent.com/98076050/396859961-b02e03eb-6f64-4a44-88e2-88badb3d3b10.jpg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDI4MzUxNzYsIm5iZiI6MTc0MjgzNDg3NiwicGF0aCI6Ii85ODA3NjA1MC8zOTY4NTk5NjEtYjAyZTAzZWItNmY2NC00YTQ0LTg4ZTItODhiYWRiM2QzYjEwLmpwZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTAzMjQlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwMzI0VDE2NDc1NlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWQzZWE1OTlhNDFhYzk5MGYwYWZiNDg4MGMwNDllOTMzNGE5MTFlZGQ2NDY5MmViZTgzZDhiMTM3YWE1ODY5NmUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.LO8fsMErFZAKahjnYeQk8nHpzc3Cpug0n_-6fq3R4K4"
    }
}
