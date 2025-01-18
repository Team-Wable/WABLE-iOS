//
//  MigratedDetailViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/16/25.
//

import Foundation
import Combine

final class MigratedDetailViewModel {
    
    let replySubject = CurrentValueSubject<[FlattenReplyModel], Never>([])
    
    private var unflattenReplySubject = CurrentValueSubject<[FeedReplyListDTO]?, Never>([])
    private var cursor: Int = -1
    private var superReplyCount = 0
    
    private let service: HomeAPI
    private let contentID: Int
    
    init(service: HomeAPI = HomeAPI.shared, contentID: Int) {
        self.service = service
        self.contentID = contentID
    }
}

extension MigratedDetailViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let collectionViewDidRefresh: AnyPublisher<Void, Never>
        let collectionViewDidEndDrag: AnyPublisher<Void, Never>
        let replyButtonDidTapped: AnyPublisher<Int?, Never>
    }
    
    struct Output {
        let feedData: AnyPublisher<HomeFeedDTO?, Never>
        let replyDatas: AnyPublisher<[FlattenReplyModel], Never>
        let changedPlaceholder: AnyPublisher<String, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        
        let feedData = input.viewDidLoad
            .merge(with: input.collectionViewDidRefresh)
            .flatMap { [weak self] _ -> AnyPublisher<HomeFeedDTO?, Never> in
                guard let self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return service.getSpecificFeed(contentID: contentID)
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        input.viewDidLoad
            .merge(with: input.collectionViewDidRefresh)
            .flatMap { [weak self] _ -> AnyPublisher<[FlattenReplyModel], Never> in
                
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return resetCursorAndGetReply()
            }
            .subscribe(replySubject)
            .store(in: cancelBag)
        
        let lastCommentIDPublisher = input.collectionViewDidEndDrag
            .compactMap {
                self.unflattenReplySubject.value?.last?.commentID
            }
        
        let replyPublisher = lastCommentIDPublisher
            .filter { [weak self] lastCommentID in
                guard let self else { return false }
                let count = unflattenReplySubject.value?.count ?? 0
                return count % 10 == 0 &&
                lastCommentID != -1 &&
                lastCommentID != cursor
            }
            .flatMap { [weak self] lastCommentID -> AnyPublisher<[FlattenReplyModel], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                cursor = lastCommentID
                return self.getReply(cursor: lastCommentID, contentID: contentID)
            }
            .map { replyData in
                var previousReply = self.replySubject.value
                previousReply.append(contentsOf: replyData)
                return previousReply
            }
        
        replyPublisher
            .subscribe(replySubject)
            .store(in: cancelBag)
        
        let replies = replySubject
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
        
        return Output(
            feedData: feedData,
            replyDatas: replies, changedPlaceholder: <#AnyPublisher<String, Never>#>
        )
    }
    
}

private extension MigratedDetailViewModel {
    func getReply(cursor: Int, contentID: Int) -> AnyPublisher<[FlattenReplyModel], Never> {
        service.getReply(cursor: cursor, contentID: contentID)
            .mapWableNetworkError()
            .replaceError(with: [])
            .handleEvents(receiveOutput: { [weak self] data in
                self?.unflattenReplySubject.send(data)
            })
            .compactMap { $0?.toFlattenedReplyList() }
            .eraseToAnyPublisher()
    }
    
    
    
    func resetCursorAndGetReply() -> AnyPublisher<[FlattenReplyModel], Never> {
        cursor = -1
        superReplyCount = 0
        // 댓글 삭제했을 때의 카운트도 생성
        return getReply(cursor: cursor, contentID: contentID)
    }

}
