//
//  MigratedHomeViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 12/24/24.
//

import Foundation
import Combine

final class MigratedHomeViewModel {
    private var cursor: Int = -1
    private var deletedFeedCount: Int = 0
    let feedSubject = CurrentValueSubject<[HomeFeedDTO], Never>([])
    
    private let service: HomeAPI
    
    init(service: HomeAPI = HomeAPI.shared) {
        self.service = service
    }
}

extension MigratedHomeViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let collectionViewDidRefresh: AnyPublisher<Void, Never>
        let collectionViewDidSelect: AnyPublisher<Int, Never>
        let collectionViewDidEndDrag: AnyPublisher<Void, Never>
        let menuButtonDidTap: AnyPublisher<Int, Never>
        let profileImageDidTap: AnyPublisher<Int, Never>
        let feedImageURL: AnyPublisher<Int, Never>
        let heartButtonDidTap: AnyPublisher<Int, Never>
        let commentButtonDidTap: AnyPublisher<Int, Never>
    }
    
    struct Output {
        let feedData: AnyPublisher<[HomeFeedDTO], Never>
        let selectedFeed: AnyPublisher<HomeFeedDTO, Never>
        let showBottomSheet: AnyPublisher<HomeFeedDTO, Never>
        let profileImageTapped: AnyPublisher<Int, Never>
        let feedImageTapped: AnyPublisher<String, Never>
        let toggleHeartButton: AnyPublisher<([HomeFeedDTO], Int), Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        
        input.viewDidLoad
            .merge(with: input.collectionViewDidRefresh)
            .flatMap { [weak self] _ -> AnyPublisher<[HomeFeedDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return resetCursorAndGetHomeFeed()
            }
            .subscribe(feedSubject)
            .store(in: cancelBag)
        
        let lastContentIDPublisher = input.collectionViewDidEndDrag
            .compactMap {
                self.feedSubject.value.last?.contentID
            }
        
        let feedPublisher = lastContentIDPublisher
            .filter { [weak self] lastContentID in // 페이지네이션 조건 필터링
                guard let self else { return false }
                let count = feedSubject.value.count + deletedFeedCount
                return count % 20 == 0 &&
                lastContentID != -1 &&
                lastContentID != cursor
            }
            .flatMap { [weak self] lastContentID -> AnyPublisher<[HomeFeedDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                cursor = lastContentID
                return self.getHomeFeed(cursor: lastContentID)
            }
            .map { feeds in
                var previousFeeds = self.feedSubject.value
                previousFeeds.append(contentsOf: feeds)
                return previousFeeds
            }

        // feedPublisher를 feedSubject에 구독
        feedPublisher
            .subscribe(feedSubject)
            .store(in: cancelBag)
        
        let feed = feedSubject
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
        
        // 인덱스 초과를 방지하기 위해서 filter로 검사해준 뒤, 인덱스에 맞는 값 찾아줌
        let selectedFeed = input.collectionViewDidSelect
            .merge(with: input.commentButtonDidTap)
            .filter { $0 < self.feedSubject.value.count}
            .map { self.feedSubject.value[$0] }
            .eraseToAnyPublisher()
        
        let profileImageDidTap = input.profileImageDidTap
            .compactMap { $0 }
            .filter { $0 < self.feedSubject.value.count }
            .map { self.feedSubject.value[$0].memberID }
            .eraseToAnyPublisher()
        
        let feedImageURL = input.feedImageURL
            .compactMap { $0 }
            .filter { $0 < self.feedSubject.value.count }
            .map { self.feedSubject.value[$0].contentImageURL ?? String() }
            .eraseToAnyPublisher()
        
        let bottomSheetInfo = input.menuButtonDidTap
            .compactMap { $0 }
            .filter { $0 < self.feedSubject.value.count }
            .map { self.feedSubject.value[$0] }
            .eraseToAnyPublisher()
                
        
        let heartButtonState = input.heartButtonDidTap
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: false)
            .compactMap { $0 }
            .filter { $0 < self.feedSubject.value.count }
            .map { index -> (Bool?, Int?, Int) in
                let item = self.feedSubject.value[index]
                return (item.isLiked, item.contentID, index)
            }
            .flatMap { [weak self] state -> AnyPublisher<(EmptyDTO?, Int), Never> in
                guard let self = self else { return Just((nil, state.2)).eraseToAnyPublisher() }
                
                if state.0 ?? false {
                    return service.deleteFeedLike(contentID: state.1 ?? Int())
                        .replaceError(with: nil)
                        .map { return ($0, state.2) }
                        .eraseToAnyPublisher()
                } else {
                    return service.postFeedLike(contentID: state.1 ?? Int())
                        .replaceError(with: nil)
                        .map { ($0, state.2) }
                        .eraseToAnyPublisher()
                }
            }
            
        let toggleHeart = heartButtonState
            .map { [weak self] apiResult, index -> ([HomeFeedDTO], Int) in
                guard let self else {
                    return ([], index)
                }
                self.updateHeartButtonState(at: index)
                return (self.feedSubject.value, index)
            }
            .eraseToAnyPublisher()


        return Output(
            feedData: feed,
            selectedFeed: selectedFeed,
            showBottomSheet: bottomSheetInfo,
            profileImageTapped: profileImageDidTap,
            feedImageTapped: feedImageURL,
            toggleHeartButton: toggleHeart
        )
    }
    
    func deleteFeed(at contentID: Int) {
        feedSubject.value.removeAll { $0.contentID == contentID }
        deletedFeedCount += 1
    }
    
    func updateGhostState(for memberID: Int) -> [HomeFeedDTO] {
        let updatedDatas = feedSubject.value.map { item in
            guard item.memberID == memberID else { return item }
            
            return HomeFeedDTO(
                memberID: item.memberID,
                memberProfileURL: item.memberProfileURL,
                memberNickname: item.memberNickname,
                isGhost: true,
                memberGhost: item.memberGhost - 1 ,
                isLiked: item.isLiked,
                time: item.time,
                likedNumber: item.likedNumber,
                memberFanTeam: item.memberFanTeam,
                contentID: item.contentID,
                contentTitle: item.contentTitle,
                contentText: item.contentText,
                commentNumber: item.commentNumber,
                isDeleted: item.isDeleted,
                commnetNumber: item.commnetNumber,
                contentImageURL: item.contentImageURL,
                isBlind: item.isBlind
            )
        }
        feedSubject.send(updatedDatas)
        return updatedDatas
    }
    
    func updateBanState(for memberID: Int) -> [HomeFeedDTO] {
        let updatedDatas = feedSubject.value.map { item in
            guard item.memberID == memberID else { return item }
            
            return HomeFeedDTO(
                memberID: item.memberID,
                memberProfileURL: item.memberProfileURL,
                memberNickname: item.memberNickname,
                isGhost: item.isGhost,
                memberGhost: item.memberGhost,
                isLiked: item.isLiked,
                time: item.time,
                likedNumber: item.likedNumber,
                memberFanTeam: item.memberFanTeam,
                contentID: item.contentID,
                contentTitle: item.contentTitle,
                contentText: item.contentText,
                commentNumber: item.commentNumber,
                isDeleted: item.isDeleted,
                commnetNumber: item.commnetNumber,
                contentImageURL: item.contentImageURL,
                isBlind: true
            )
        }
        feedSubject.send(updatedDatas)
        return updatedDatas
    }
    
    func updateHeartButtonState(at index: Int){
        var updatedDatas = feedSubject.value
        
        guard updatedDatas.indices.contains(index) else { return }
        
        let item = updatedDatas[index]
        let newData = HomeFeedDTO(
            memberID: item.memberID,
            memberProfileURL: item.memberProfileURL,
            memberNickname: item.memberNickname,
            isGhost: item.isGhost,
            memberGhost: item.memberGhost,
            isLiked: !item.isLiked,
            time: item.time,
            likedNumber: item.isLiked ? item.likedNumber - 1 : item.likedNumber + 1,
            memberFanTeam: item.memberFanTeam,
            contentID: item.contentID,
            contentTitle: item.contentTitle,
            contentText: item.contentText,
            commentNumber: item.commentNumber,
            isDeleted: item.isDeleted,
            commnetNumber: item.commnetNumber,
            contentImageURL: item.contentImageURL,
            isBlind: item.isBlind
        )
        
        updatedDatas[index] = newData
        
        feedSubject.send(updatedDatas)
    }
}

private extension MigratedHomeViewModel {
    func getHomeFeed(cursor: Int) -> AnyPublisher<[HomeFeedDTO], Never> {
        service.migratedGetHomeFeed(cursor: cursor)
            .mapWableNetworkError()
            .replaceError(with: [])
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func resetCursorAndGetHomeFeed() -> AnyPublisher<[HomeFeedDTO], Never> {
        cursor = -1
        deletedFeedCount = 0
        return getHomeFeed(cursor: cursor)
    }
}
