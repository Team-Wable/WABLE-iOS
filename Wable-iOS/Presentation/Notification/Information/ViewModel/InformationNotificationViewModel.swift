//
//  InformationNotificationViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/30/25.
//

import Combine
import Foundation

final class InformationNotificationViewModel {
    private let useCase: NotificationUseCase
    
    init(useCase: NotificationUseCase) {
        self.useCase = useCase
    }
}

extension InformationNotificationViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<Int, Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let notifications: AnyPublisher<[InformationNotification], Never>
        let selectedNotification: AnyPublisher<InformationNotification, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let notificationsSubject = CurrentValueSubject<[InformationNotification], Never>([])
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
            .flatMap { owner, _ -> AnyPublisher<[InformationNotification], Never> in
                return owner.fetchNotifications(for: Constant.initialCursor)
            }
            .handleEvents(receiveOutput: { [weak self] notifications in
                isLoadingSubject.send(false)
                isLastPageSubject.send(self?.isLastPage(notifications) ?? true)
            })
            .sink { notificationsSubject.send($0) }
            .store(in: cancelBag)
        
        input.willDisplayLastItem
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isLoadingMoreSubject.value && !isLastPageSubject.value && !notificationsSubject.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isLoadingMoreSubject.send(true)
            })
            .compactMap { notificationsSubject.value.last?.id }
            .withUnretained(self)
            .flatMap { owner, lastItemID -> AnyPublisher<[InformationNotification], Never> in
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
            .eraseToAnyPublisher()
        
        return Output(
            notifications: notificationsSubject.eraseToAnyPublisher(),
            selectedNotification: selectedNotification.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension InformationNotificationViewModel {
    func fetchNotifications(for lastItemID: Int) -> AnyPublisher<[InformationNotification], Never> {
        return useCase.fetchInformationNotifications(for: lastItemID)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func isLastPage(_ notifications: [InformationNotification]) -> Bool {
        return notifications.isEmpty || notifications.count < Constant.defaultItemsCountPerPage
    }
}

// MARK: - Constant

private extension InformationNotificationViewModel {
    enum Constant {
        static let defaultItemsCountPerPage: Int = 15
        static let initialCursor: Int = -1
    }
}
