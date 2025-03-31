//
//  NoticeViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/25/25.
//

import Combine
import Foundation

final class NoticeViewModel {
    private let useCase: OverviewUseCase
    
    init(useCase: OverviewUseCase) {
        self.useCase = useCase
    }
}

extension NoticeViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<Int, Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let notices: AnyPublisher<[Announcement], Never>
        let selectedNotice: AnyPublisher<Announcement, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let noticesSubject = CurrentValueSubject<[Announcement], Never>([])
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
        let isLastPageSubject = CurrentValueSubject<Bool, Never>(false)
                
        Publishers.Merge(input.viewDidLoad, input.viewDidRefresh)
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
                isLastPageSubject.send(false)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Announcement], Never> in
                return owner.fetchNotices(with: Constant.initialCursor)
            }
            .handleEvents(receiveOutput: { [weak self] notices in
                isLoadingSubject.send(false)
                isLastPageSubject.send(self?.isLastPage(notices) ?? false)
            })
            .sink { noticesSubject.send($0) }
            .store(in: cancelBag)
        
        input.willDisplayLastItem
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isLoadingMoreSubject.value && !isLastPageSubject.value && !noticesSubject.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isLoadingMoreSubject.send(true)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Announcement], Never> in
                guard let lastItem = noticesSubject.value.last else {
                    return .just([])
                }
                return owner.fetchNotices(with: lastItem.id)
            }
            .handleEvents(receiveOutput: { [weak self] notices in
                isLoadingMoreSubject.send(false)
                isLastPageSubject.send(self?.isLastPage(notices) ?? true)
            })
            .filter { !$0.isEmpty }
            .sink { notices in
                var currentItems = noticesSubject.value
                currentItems.append(contentsOf: notices)
                noticesSubject.send(currentItems)
            }
            .store(in: cancelBag)
        
        let selectedNotice = input.didSelectItem
            .filter { $0 < noticesSubject.value.count }
            .map { noticesSubject.value[$0] }
            .eraseToAnyPublisher()
        
        return Output(
            notices: noticesSubject.eraseToAnyPublisher(),
            selectedNotice: selectedNotice,
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension NoticeViewModel {
    func fetchNotices(with lastItemID: Int) -> AnyPublisher<[Announcement], Never> {
        return useCase.fetchNotices(with: lastItemID)
            .catch { error -> AnyPublisher<[Announcement], Never> in
                WableLogger.log("에러 발생: \(error.localizedDescription)", for: .error)
                return .just([])
            }
            .eraseToAnyPublisher()
    }
    
    func isLastPage(_ notices: [Announcement]) -> Bool {
        return notices.isEmpty || notices.count < Constant.defaultItemsCountPerPage
    }
}

// MARK: - Constant

private extension NoticeViewModel {
    enum Constant {
        static let defaultItemsCountPerPage: Int = 15
        static let initialCursor: Int = -1
    }
}
