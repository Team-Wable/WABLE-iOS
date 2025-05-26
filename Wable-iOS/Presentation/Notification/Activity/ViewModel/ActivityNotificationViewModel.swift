//
//  ActivityNotificationViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/31/25.
//

import Combine
import UIKit

final class ActivityNotificationViewModel {
    private let useCase: NotificationUseCase
    private let userBadgeUseCase: UpdateUserBadgeUseCase
    private let userInformationUseCase: FetchUserInformationUseCase
    
    init(
        useCase: NotificationUseCase,
        userBadgeUseCase: UpdateUserBadgeUseCase,
        userInformationUseCase: FetchUserInformationUseCase
    ) {
        self.useCase = useCase
        self.userBadgeUseCase = userBadgeUseCase
        self.userInformationUseCase = userInformationUseCase
    }
}

extension ActivityNotificationViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<Int, Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
        let profileImageViewDidTap: AnyPublisher<Int, Never>
    }
    
    struct Output {
        let notifications: AnyPublisher<[ActivityNotification], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
        let content: AnyPublisher<Int, Never>
        let writeContent: AnyPublisher<Void, Never>
        let googleForm: AnyPublisher<Void, Never>
        let user: AnyPublisher<Int, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let notificationsSubject = CurrentValueSubject<[ActivityNotification], Never>([])
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
        let isLastPageSubject = CurrentValueSubject<Bool, Never>(false)
        let loadTrigger = Publishers.Merge(input.viewDidLoad, input.viewDidRefresh)
        
        loadTrigger
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
                isLastPageSubject.send(false)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[ActivityNotification], Never> in
                return owner.fetchNotifications(for: Constant.initialCursor)
            }
            .handleEvents(receiveOutput: { [weak self] notifications in
                isLoadingSubject.send(false)
                isLastPageSubject.send(self?.isLastPage(notifications) ?? false)
            })
            .sink { notificationsSubject.send($0) }
            .store(in: cancelBag)
        
        loadTrigger
            .withUnretained(self)
            .sink { owner, _ in
                owner.userBadgeUseCase.execute(number: 0)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            WableLogger.log("뱃지 수정 중 오류 발생: \(error)", for: .error)
                        }
                    } receiveValue: { [weak self] _ in
                        guard let self = self else { return }
                        
                        self.userInformationUseCase.fetchActiveUserID()
                            .sink { [weak self] id in
                                guard let self = self,
                                      let id = id
                                else {
                                    return
                                }
                                
                                self.userInformationUseCase.updateUserSession(userID: id, notificationBadgeCount: 0)
                                    .sink { _ in }
                                    .store(in: cancelBag)
                                
                                UIApplication.shared.applicationIconBadgeNumber = 0
                            }
                            .store(in: cancelBag)
                    }
                    .store(in: cancelBag)
            }
            .store(in: cancelBag)
        
        input.willDisplayLastItem
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isLoadingSubject.value && !isLastPageSubject.value && !notificationsSubject.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isLoadingMoreSubject.send(true)
            })
            .compactMap { notificationsSubject.value.last?.id }
            .withUnretained(self)
            .flatMap { owner, lastItemID -> AnyPublisher<[ActivityNotification], Never> in
                return owner.fetchNotifications(for: lastItemID)
            }
            .handleEvents(receiveOutput: { [weak self] notifications in
                isLoadingMoreSubject.send(false)
                isLastPageSubject.send(self?.isLastPage(notifications) ?? true)
            })
            .filter { !$0.isEmpty }
            .sink { notifications in
                var currentItems = notificationsSubject.value
                currentItems.append(contentsOf: notifications)
                notificationsSubject.send(currentItems)
            }
            .store(in: cancelBag)
        
        let selectedNotification = input.didSelectItem
            .filter { $0 < notificationsSubject.value.count }
            .map { notificationsSubject.value[$0] }
            .share()
        
        let content = selectedNotification
            .filter {
                guard let type = $0.type else {
                    return false
                }
                return TriggerType.ActivityNotification.contentTypes.contains(type)
            }
            .map { $0.triggerID }
            .eraseToAnyPublisher()
        
        let writeContent = selectedNotification
            .filter {
                guard let type = $0.type else {
                    return false
                }
                return TriggerType.ActivityNotification.writeContentTypes.contains(type)
            }
            .asVoid()
        
        let googleForm = selectedNotification
            .filter {
                guard let type = $0.type else {
                    return false
                }
                return TriggerType.ActivityNotification.googleFormTypes.contains(type)
            }
            .asVoid()
        
        let user = input.profileImageViewDidTap
            .filter { $0 < notificationsSubject.value.count }
            .map { notificationsSubject.value[$0] }
            .map { $0.triggerUserID }
            .eraseToAnyPublisher()
        
        return Output(
            notifications: notificationsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher(),
            content: content,
            writeContent: writeContent,
            googleForm: googleForm,
            user: user
        )
    }
}

// MARK: - Helper Method

private extension ActivityNotificationViewModel {
    func fetchNotifications(for lastItemID: Int) -> AnyPublisher<[ActivityNotification], Never> {
        return useCase.fetchActivityNotifications(for: lastItemID)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func isLastPage(_ notifications: [ActivityNotification]) -> Bool {
        return notifications.isEmpty || notifications.count < Constant.defaultItemsCountPerPage
    }
}

// MARK: - Constant

private extension ActivityNotificationViewModel {
    enum Constant {
        static let defaultItemsCountPerPage: Int = 15
        static let initialCursor: Int = -1
    }
}
