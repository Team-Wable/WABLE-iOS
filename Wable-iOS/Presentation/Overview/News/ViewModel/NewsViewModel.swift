//
//  NewsViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Combine
import Foundation

final class NewsViewModel {
    private let useCase: OverviewUseCase
    
    init(useCase: OverviewUseCase) {
        self.useCase = useCase
    }
}

extension NewsViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<Int, Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let news: AnyPublisher<[Announcement], Never>
        let selectedNews: AnyPublisher<Announcement, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let newsSubject = CurrentValueSubject<[Announcement], Never>([])
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
                return owner.fetchNews(with: IntegerLiterals.initialCursor)
            }
            .handleEvents(receiveOutput: { [weak self] news in
                isLoadingSubject.send(false)
                isLastPageSubject.send(self?.isLastPage(news) ?? false)
            })
            .sink { news in
                newsSubject.send(news)
            }
            .store(in: cancelBag)
        
        input.willDisplayLastItem
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isLoadingMoreSubject.value && !isLastPageSubject.value && !newsSubject.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isLoadingMoreSubject.send(true)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Announcement], Never> in
                guard let lastItem = newsSubject.value.last else {
                    return .just([])
                }
                return owner.fetchNews(with: lastItem.id)
            }
            .handleEvents(receiveOutput: { [weak self] news in
                isLoadingMoreSubject.send(false)
                isLastPageSubject.send(self?.isLastPage(news) ?? true)
            })
            .filter { !$0.isEmpty }
            .sink { news in
                var currentItems = newsSubject.value
                currentItems.append(contentsOf: news)
                newsSubject.send(currentItems)
            }
            .store(in: cancelBag)
        
        let selectedNews = input.didSelectItem
            .filter { $0 < newsSubject.value.count }
            .map { newsSubject.value[$0] }
            .eraseToAnyPublisher()
        
        return Output(
            news: newsSubject.eraseToAnyPublisher(),
            selectedNews: selectedNews,
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension NewsViewModel {
    func fetchNews(with lastItemID: Int) -> AnyPublisher<[Announcement], Never> {
        return useCase.fetchNews(with: lastItemID)
            .catch { error -> AnyPublisher<[Announcement], Never> in
                WableLogger.log("에러 발생: \(error.localizedDescription)", for: .error)
                return .just([])
            }
            .eraseToAnyPublisher()
    }
    
    func isLastPage(_ news: [Announcement]) -> Bool {
        return news.isEmpty || news.count < IntegerLiterals.defaultCountPerPage
    }
}
