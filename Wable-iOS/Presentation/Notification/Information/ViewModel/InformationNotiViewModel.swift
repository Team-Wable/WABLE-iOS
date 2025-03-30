//
//  InformationNotiViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/30/25.
//

import Combine
import Foundation

final class InformationNotiViewModel {
    private let notificationRepository: NotificationRepository
    
    init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }
}

extension InformationNotiViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<Int, Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let notifications: AnyPublisher<[InfoNotification], Never>
        let selectedNotification: AnyPublisher<InfoNotification, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let notificationsSubject = CurrentValueSubject<[InfoNotification], Never>([])
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
            .flatMap { owner, _ -> AnyPublisher<[InfoNotification], Never> in
                return owner.notificationRepository.fetchInfoNotifications(cursor: Constant.initialCursor)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { notifications in
                isLoadingSubject.send(false)
                let isLastPage = notifications.isEmpty || notifications.count < Constant.defaultItemsCountPerPage
                isLastPageSubject.send(isLastPage)
            })
            .sink { notificationsSubject.send($0) }
            .store(in: cancelBag)
        
        input.willDisplayLastItem
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isLoadingMoreSubject.value && !isLastPageSubject.value && !notificationsSubject.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isLoadingMoreSubject.send(true)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[InfoNotification], Never> in
                guard let lastItem = notificationsSubject.value.last else {
                    return .just([])
                }
                
                let cursor = lastItem.id
                return owner.notificationRepository.fetchInfoNotifications(cursor: cursor)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { notifications in
                isLoadingMoreSubject.send(false)
                let isLastPage = notifications.isEmpty || notifications.count < Constant.defaultItemsCountPerPage
                isLastPageSubject.send(isLastPage)
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

private extension InformationNotiViewModel {
    enum Constant {
        static let defaultItemsCountPerPage: Int = 15
        static let initialCursor: Int = -1
    }
}
