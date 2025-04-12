//
//  NotificationUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//

import Combine
import Foundation

// MARK: - NotificationUseCase

protocol NotificationUseCase {
    func fetchActivityNotifications(for lastItemID: Int) -> AnyPublisher<[ActivityNotification], WableError>
    func fetchInformationNotifications(for lastItemID: Int) -> AnyPublisher<[InformationNotification], WableError>
}

// MARK: - NotificationUseCaseImpl

final class NotificationUseCaseImpl: NotificationUseCase {
    private let notificationRepository: NotificationRepository
    
    init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }
    
    func fetchActivityNotifications(for lastItemID: Int) -> AnyPublisher<[ActivityNotification], WableError> {
        _ = notificationRepository.checkNotification()
        
        return notificationRepository.fetchUserNotifications(cursor: lastItemID)
            .eraseToAnyPublisher()
    }
    
    func fetchInformationNotifications(for lastItemID: Int) -> AnyPublisher<[InformationNotification], WableError> {
        return notificationRepository.fetchInfoNotifications(cursor: lastItemID)
            .eraseToAnyPublisher()
    }
}

// MARK: - MockNotificationUseCaseImpl

struct MockNotificationUseCaseImpl: NotificationUseCase {
    private var randomDelaySecond: Double { .random(in: 0.3...1.0) }
    
    func fetchActivityNotifications(for lastItemID: Int) -> AnyPublisher<[ActivityNotification], WableError> {
        let range = getPaginationRange(for: lastItemID)
        
        if range == nil {
            return emptyPublisher()
        }
        
        let types: [TriggerType.ActivityNotification] = [
            .contentLike, .commentLike, .comment, .contentGhost,
            .commentGhost, .beGhost, .actingContinue, .userBan,
            .popularWriter, .popularContent, .childComment, .childCommentLike
        ]
        
        return .just(range!.map { id in
            ActivityNotification(
                id: id,
                triggerID: 720,
                type: types.randomElement(),
                time: getRelativeDate(for: id),
                targetContentText: "샘플 콘텐츠 \(id)",
                userID: Int.random(in: 1...100),
                userNickname: "사용자\(id)",
                triggerUserID: Int.random(in: 1...100),
                triggerUserNickname: "트리거사용자\(id)",
                triggerUserProfileURL: getSampleImageURL(),
                isChecked: Bool.random(),
                isDeletedUser: Bool.random()
            )
        })
        .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func fetchInformationNotifications(for lastItemID: Int) -> AnyPublisher<[InformationNotification], WableError> {
        let range = getPaginationRange(for: lastItemID, maxPage: 33)
        
        if range == nil {
            return emptyPublisher()
        }
        
        let types: [InformationNotificationType] = [.gameDone, .gameStart, .weekDone]
        
        return .just(range!.map { id in
            InformationNotification(
                id: id,
                type: types.randomElement(),
                time: getRelativeDate(for: id),
                imageURL: getSampleImageURL()
            )
        })
        .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private func getPaginationRange(for lastItemID: Int, maxPage: Int = 33) -> ClosedRange<Int>? {
        switch lastItemID {
        case -1:
            return 1...15
        case 15:
            return 16...30
        case 30:
            return 31...maxPage
        default:
            return nil
        }
    }
    
    private func getRelativeDate(for id: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: -id, to: Date())
    }
    
    private func getSampleImageURL() -> URL? {
        return URL(string: Constant.imageURLText)
    }
    
    private func emptyPublisher<T>() -> AnyPublisher<[T], WableError> {
        return .just([])
            .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private enum Constant {
        static let imageURLText: String = "https://private-user-images.githubusercontent.com/80394340/349682631-566a0a8c-c673-4650-b9f4-3b74d7443aa9.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDMzODUwNjMsIm5iZiI6MTc0MzM4NDc2MywicGF0aCI6Ii84MDM5NDM0MC8zNDk2ODI2MzEtNTY2YTBhOGMtYzY3My00NjUwLWI5ZjQtM2I3NGQ3NDQzYWE5LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTAzMzElMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwMzMxVDAxMzI0M1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTRiMjJlZDIyOGU2M2E3NTBiMGQyMjUyNWI0MGQxYTk0ZGVkZmIyNWY2ZjY0YjVmZTQxNzdiMzQ0NzkxNTMzNmQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.fslk0G5432-vBjha8bXJ6OAcCOusEowIPST_de3arwU"
    }
}
