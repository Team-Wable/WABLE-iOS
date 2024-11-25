//
//  InfoNoticeViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/26/24.
//

import Foundation
import Combine

final class InfoNoticeViewModel {
    private var cursor: Int = -1
    
    private let service: InfoAPI
    
    init(service: InfoAPI = InfoAPI.shared) {
        self.service = service
    }
}

extension InfoNoticeViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let collectionViewDidRefresh: AnyPublisher<Void, Never>
        let collectionViewDidSelect: AnyPublisher<Int, Never>
        let collectionViewDidEndDrag: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let noticeList: AnyPublisher<[NoticeDTO], Never>
        let selectedNotice: AnyPublisher<NoticeDTO, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let noticeListSubject = CurrentValueSubject<[NoticeDTO], Never>([])
        
        input.viewDidLoad
            .merge(with: input.collectionViewDidRefresh)
            .flatMap { [weak self] _ -> AnyPublisher<[NoticeDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return resetCursorAndFetchNoticeList()
            }
            .subscribe(noticeListSubject)
            .store(in: cancelBag)
        
        input.collectionViewDidEndDrag
            .compactMap { noticeListSubject.value.last?.id }
            .filter { [weak self] lastNewsID in
                noticeListSubject.value.count % 15 == 0 &&
                lastNewsID != -1 &&
                lastNewsID != self?.cursor ?? .zero
            }
            .flatMap { [weak self] lastNewsID -> AnyPublisher<[NoticeDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                cursor = lastNewsID
                return fetchNoticeList(cursor: lastNewsID)
            }
            .map { news in
                var previousNews = noticeListSubject.value
                previousNews.append(contentsOf: news)
                return previousNews
            }
            .subscribe(noticeListSubject)
            .store(in: cancelBag)
        
        let noticeList = noticeListSubject
            .map { NoticeTimeFormatter().formattedNews(news: $0) }
            .eraseToAnyPublisher()
        
        let selectedNoticeList = input.collectionViewDidSelect
            .filter { $0 < noticeListSubject.value.count }
            .map { noticeListSubject.value[$0] }
            .map { NoticeTimeFormatter().formattedNews(news: $0) }
            .eraseToAnyPublisher()
        
        return Output(
            noticeList: noticeList,
            selectedNotice: selectedNoticeList
        )
    }
}

private extension InfoNoticeViewModel {
    func fetchNoticeList(cursor: Int) -> AnyPublisher<[NoticeDTO], Never> {
        service.getNotice(cursor: cursor)
            .mapWableNetworkError()
            .replaceError(with: [])
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func resetCursorAndFetchNoticeList() -> AnyPublisher<[NoticeDTO], Never> {
        cursor = -1
        return fetchNoticeList(cursor: cursor)
    }
}
