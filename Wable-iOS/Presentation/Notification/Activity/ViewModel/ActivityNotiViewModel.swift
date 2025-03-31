//
//  ActivityNotiViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/31/25.
//

import Combine
import Foundation

final class ActivityNotiViewModel {
    private let useCase: NotificationUseCase
    
    init(useCase: NotificationUseCase) {
        self.useCase = useCase
    }
}

extension ActivityNotiViewModel: ViewModelType {
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
        
        Publishers.Merge(input.viewDidLoad, input.viewDidRefresh)
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

private extension ActivityNotiViewModel {
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

private extension ActivityNotiViewModel {
    enum Constant {
        static let defaultItemsCountPerPage: Int = 15
        static let initialCursor: Int = -1
    }
}
