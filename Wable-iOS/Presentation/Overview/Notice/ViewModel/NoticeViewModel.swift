//
//  NoticeViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/25/25.
//

import Combine
import Foundation

final class NoticeViewModel {
    private let overviewRepository: InformationRepository
    
    init(overviewRepository: InformationRepository) {
        self.overviewRepository = overviewRepository
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
        
        let loadTrigger = Publishers.Merge(
            input.viewDidLoad,
            input.viewDidRefresh
        )
        
        loadTrigger
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
                isLastPageSubject.send(false)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Announcement], Never> in
                return owner.overviewRepository.fetchNotice(cursor: Constant.initialCursor)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { news in
                isLoadingSubject.send(false)
                isLastPageSubject.send(news.isEmpty || news.count < Constant.defaultNewsCountPerPage)
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
                
                let cursor = lastItem.id
                return owner.overviewRepository.fetchNews(cursor: cursor)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { news in
                isLoadingMoreSubject.send(false)
                isLastPageSubject.send(news.isEmpty || news.count < Constant.defaultNewsCountPerPage)
            })
            .filter { !$0.isEmpty }
            .sink { news in
                var currentItems = noticesSubject.value
                currentItems.append(contentsOf: news)
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

private extension NoticeViewModel {
    enum Constant {
        static let defaultNewsCountPerPage: Int = 15
        static let initialCursor: Int = -1
    }
}
