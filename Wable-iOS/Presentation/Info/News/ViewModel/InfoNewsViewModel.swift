//
//  InfoNewsViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import Foundation
import Combine

final class InfoNewsViewModel {
    private var cursor: Int = -1
    
    private let service: InfoAPI
    
    init(service: InfoAPI = InfoAPI.shared) {
        self.service = service
    }
}

extension InfoNewsViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let collectionViewDidRefresh: AnyPublisher<Void, Never>
        let collectionViewDidSelect: AnyPublisher<Int, Never>
        let collectionViewDidEndDrag: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let news: AnyPublisher<[NewsDTO], Never>
        let selectedNews: AnyPublisher<NewsDTO, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let newsSubject = CurrentValueSubject<[NewsDTO], Never>([])
        
        input.viewDidLoad
            .merge(with: input.collectionViewDidRefresh)
            .flatMap { [weak self] _ -> AnyPublisher<[NewsDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return resetCursorAndFetchNews()
            }
            .subscribe(newsSubject)
            .store(in: cancelBag)
        
        input.collectionViewDidEndDrag
            .compactMap { newsSubject.value.last?.id }
            .filter { [weak self] lastNewsID in
                newsSubject.value.count % 15 == 0 &&
                lastNewsID != -1 &&
                lastNewsID != self?.cursor ?? .zero
            }
            .flatMap { [weak self] lastNewsID -> AnyPublisher<[NewsDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                cursor = lastNewsID
                return fetchNews(cursor: lastNewsID)
            }
            .map { news in
                var previousNews = newsSubject.value
                previousNews.append(contentsOf: news)
                return previousNews
            }
            .subscribe(newsSubject)
            .store(in: cancelBag)
        
        let news = newsSubject
            .map { NewsTimeFormatter().formattedNews(news: $0) }
            .eraseToAnyPublisher()
        
        let selectedNews = input.collectionViewDidSelect
            .filter { $0 < newsSubject.value.count }
            .map { newsSubject.value[$0] }
            .map { NewsTimeFormatter().formattedNews(news: $0) }
            .eraseToAnyPublisher()
        
        return Output(
            news: news,
            selectedNews: selectedNews
        )
    }
}

private extension InfoNewsViewModel {
    func fetchNews(cursor: Int) -> AnyPublisher<[NewsDTO], Never> {
        service.getNews(cursor: cursor)
            .mapWableNetworkError()
            .replaceError(with: [])
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func resetCursorAndFetchNews() -> AnyPublisher<[NewsDTO], Never> {
        cursor = -1
        return fetchNews(cursor: cursor)
    }
}
