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
        let viewWillAppear: AnyPublisher<Void, Never>
        let collectionViewDidRefresh: AnyPublisher<Void, Never>
        let collectionViewDidSelect: AnyPublisher<Int, Never>
        let collectionViewDidEndDrag: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let news: AnyPublisher<[NewsDTO], Never>
        let navigateToDetail: AnyPublisher<NewsDTO, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let news = CurrentValueSubject<[NewsDTO], Never>([])
        
        input.viewWillAppear
            .flatMap { [weak self] _ -> AnyPublisher<[NewsDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return service.getNews(cursor: -1)
                    .mapWableNetworkError()
                    .replaceError(with: [])
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .map { NewsTimeFormatter(news: $0).formattedNews() }
            .subscribe(news)
            .store(in: cancelBag)
        
        input.collectionViewDidRefresh
            .handleEvents(receiveRequest: { [weak self] _ in
                self?.cursor = -1
            })
            .flatMap { [weak self] _ -> AnyPublisher<[NewsDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return service.getNews(cursor: -1)
                    .mapWableNetworkError()
                    .replaceError(with: [])
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .map { NewsTimeFormatter(news: $0).formattedNews() }
            .subscribe(news)
            .store(in: cancelBag)
        
        let navigateToDetail = input.collectionViewDidSelect
            .filter { $0 < news.value.count }
            .map { news.value[$0] }
            .eraseToAnyPublisher()
        
        return Output(
            news: news.eraseToAnyPublisher(),
            navigateToDetail: navigateToDetail
        )
    }
}
