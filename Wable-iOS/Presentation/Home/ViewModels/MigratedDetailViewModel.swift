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
    let feedSubject = CurrentValueSubject<HomeFeedDTO?, Never>(nil)
    
    private var cursor: Int = -1
    private var superReplyCount = 0
    
    private let parentCommentAndWriterID = CurrentValueSubject<(Int, Int),Never>((-1, -1))
    private let unflattenReplySubject = CurrentValueSubject<[FeedReplyListDTO], Never>([])
    
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
        let replyButtonDidTapped: AnyPublisher<FlattenReplyModel?, Never>
        let menuButtonDidTapped: AnyPublisher<FlattenReplyModel?, Never>
        let profileImageDidTapped: AnyPublisher<FlattenReplyModel?, Never>
        let heartButtonDidTapped: AnyPublisher<FlattenReplyModel?, Never>
        let feedImageURL: AnyPublisher<Void, Never>
        let postReplyButtonDidTapped: AnyPublisher<String, Never>
    }
    
    struct Output {
        let feedData: AnyPublisher<HomeFeedDTO?, Never>
        let replyDatas: AnyPublisher<[FlattenReplyModel], Never>
        let changedPlaceholder: AnyPublisher<String, Never>
        let profileImageTapped: AnyPublisher<Int, Never>
        let showBottomSheet: AnyPublisher<PopupModel, Never>
        let toggleFeedHeartButton: AnyPublisher<HomeFeedDTO, Never>
        let toggleReplyHeartButton: AnyPublisher<[FlattenReplyModel], Never>
        let feedImageTapped: AnyPublisher<String, Never>
        let postReplyComplete: AnyPublisher<Void, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        
        let placeholder = CurrentValueSubject<String, Never>("")
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
                    .handleEvents(receiveOutput: { feedData in
                        let nickname = feedData?.memberNickname ?? ""
                        placeholder.send(nickname + StringLiterals.Home.placeholder)
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        feedData
            .map { feedData in
                self.addContentID(data: feedData, contentID: self.contentID)
            }
            .subscribe(feedSubject)
            .store(in: cancelBag)
                
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
                self.unflattenReplySubject.value.last?.commentID
            }
        
        let replyPublisher = lastCommentIDPublisher
            .filter { [weak self] lastCommentID in
                guard let self else { return false }
                let count = unflattenReplySubject.value.count
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
        
        input.replyButtonDidTapped
            .sink { [weak self] reply in
                guard let self else { return }
                if let reply = reply {
                    let parentCommentID = reply.commentID
                    let parentWriterID = reply.memberID
                    let parentNickname = reply.memberNickname
                    
                    parentCommentAndWriterID.send((parentCommentID, parentWriterID))
                    placeholder.send(parentNickname + StringLiterals.Home.placeholderForChildReply)
                } else {
                    parentCommentAndWriterID.send((-1, -1))
                    let nickname = feedSubject.value?.memberNickname ?? ""
                    placeholder.send(nickname + StringLiterals.Home.placeholder)
                }
            }
            .store(in: cancelBag)
        
        let profileImageDidTapped = input.profileImageDidTapped
            .map { [weak self] reply in
                if let reply = reply {
                    return reply.memberID
                } else {
                    return self?.feedSubject.value?.memberID ?? -1
                }
            }
            .eraseToAnyPublisher()
        
        let bottomSheetData = input.menuButtonDidTapped
            .map { [weak self] reply -> PopupModel in
                if let reply = reply {
                    let popupData = PopupModel(
                        memberID: reply.memberID,
                        contentType: .comment,
                        triggerID: reply.commentID,
                        nickname: reply.memberNickname,
                        relatedText: reply.commentText
                    )
                    return popupData
                } else {
                    let target = self?.feedSubject.value
                    let popupData = PopupModel(
                        memberID: target?.memberID ?? -1,
                        contentType: .content,
                        triggerID: self?.contentID ?? -1,
                        nickname: target?.memberNickname ?? "",
                        relatedText: target?.contentText ?? ""
                    )
                    return popupData
                }
            }
            .eraseToAnyPublisher()
        
        let feedHeartButtonDidTapped = input.heartButtonDidTapped
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: false)
            .filter { $0 == nil }
            .map { _ -> Bool in
                return self.feedSubject.value?.isLiked ?? false
            }
            .flatMap { [weak self] isLike -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else { return Just(nil).eraseToAnyPublisher()}
                
                if isLike {
                    return service.deleteFeedLike(contentID: contentID)
                        .replaceError(with: nil)
                        .compactMap { $0 }
                        .eraseToAnyPublisher()
                } else {
                    return service.postFeedLike(contentID: contentID)
                        .mapWableNetworkError()
                        .replaceError(with: nil)
                        .compactMap { $0 }
                        .eraseToAnyPublisher()
                }
            }
        
        let toggleFeedHeart = feedHeartButtonDidTapped
            .map { [weak self] apiResult -> HomeFeedDTO? in
                self?.updateFeedHeartButtonState()
                return self?.feedSubject.value
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        
        let replyHeartButtonDidTapped = input.heartButtonDidTapped
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: false)
            .compactMap { $0 }
        
        let heartButtonTappedReply = replyHeartButtonDidTapped
            .flatMap { [weak self] reply -> AnyPublisher<(EmptyDTO?, FlattenReplyModel), Never> in
                guard let self else {
                    return Just((nil, FlattenReplyModel(
                        commentID: -1,
                        memberID: -1,
                        memberProfileURL: "",
                        memberNickname: "",
                        isGhost: false,
                        memberGhost: -1,
                        isLiked: false,
                        commentLikedNumber: -1,
                        commentText: "",
                        time: "",
                        isDeleted: false,
                        memberFanTeam: "",
                        parentCommentID: -1,
                        isBlind: false
                    ))).eraseToAnyPublisher()
                }
                
                if reply.isLiked {
                    return service.deleteReplyLike(commentID: reply.commentID)
                        .mapWableNetworkError()
                        .replaceError(with: nil)
                        .map { ($0, reply) }
                        .eraseToAnyPublisher()
                } else {
                    return service.postReplyLike(
                        commentID: reply.commentID,
                        alarmText: reply.commentText
                    )
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .map { ($0, reply) }
                    .eraseToAnyPublisher()
                }
            }

        let toggleReplyHeart = heartButtonTappedReply
            .map { [weak self] apiResult, reply -> [FlattenReplyModel] in
                self?.updateReplyHeartButtonState(for: reply.commentID)
                return self?.replySubject.value ?? []
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        let feedImageURL = input.feedImageURL
            .map { self.feedSubject.value?.contentImageURL ?? "" }
            .eraseToAnyPublisher()
        
        let postReplyButtonDidTapped = input.postReplyButtonDidTapped
            .throttle(
                for: .milliseconds(500),
                scheduler: RunLoop.main,
                latest: false
            )
            .flatMap { [weak self] text -> AnyPublisher<Void, Never> in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                let currentState = parentCommentAndWriterID.value
                let requestBody = WriteReplyRequestV3DTO(
                    commentText: text,
                    parentCommentID: currentState.0,
                    parentCommentWriterID: currentState.1
                )
                
                return service.postReply(
                    contentID: contentID,
                    requestBody: requestBody
                )
                .mapWableNetworkError()
                .replaceError(with: nil)
                .handleEvents(receiveOutput:  { _ in
                    self.parentCommentAndWriterID.send((-1, -1))
                    let nickname = self.feedSubject.value?.memberNickname ?? ""
                    placeholder.send(nickname + StringLiterals.Home.placeholder)
                })
                .map { _ in () }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        return Output(
            feedData: feedSubject.eraseToAnyPublisher(),
            replyDatas: replies,
            changedPlaceholder: placeholder.eraseToAnyPublisher(),
            profileImageTapped: profileImageDidTapped,
            showBottomSheet: bottomSheetData,
            toggleFeedHeartButton: toggleFeedHeart,
            toggleReplyHeartButton: toggleReplyHeart,
            feedImageTapped: feedImageURL,
            postReplyComplete: postReplyButtonDidTapped
        )
    }
}

private extension MigratedDetailViewModel {
    func getReply(cursor: Int, contentID: Int) -> AnyPublisher<[FlattenReplyModel], Never> {
        service.getReply(cursor: cursor, contentID: contentID)
            .mapWableNetworkError()
            .replaceError(with: [])
            .handleEvents(receiveOutput: { [weak self] data in
                self?.unflattenReplySubject.send(data ?? [])
            })
            .compactMap { $0?.toFlattenedReplyList() }
            .eraseToAnyPublisher()
        
    }
    
    func resetCursorAndGetReply() -> AnyPublisher<[FlattenReplyModel], Never> {
        cursor = -1
        superReplyCount = 0
        return getReply(cursor: cursor, contentID: contentID)
    }
    
    func addContentID(data: HomeFeedDTO?, contentID: Int) -> HomeFeedDTO {
        let item = data ?? defalutHomeFeedDTO()
        return HomeFeedDTO(
            memberID: item.memberID,
            memberProfileURL: item.memberProfileURL,
            memberNickname: item.memberNickname,
            isGhost: item.isGhost,
            memberGhost: item.memberGhost - 1,
            isLiked: item.isLiked,
            time: item.time,
            likedNumber: item.likedNumber,
            memberFanTeam: item.memberFanTeam,
            contentID: contentID,
            contentTitle: item.contentTitle,
            contentText: item.contentText,
            commentNumber: item.commentNumber,
            isDeleted: item.isDeleted,
            commnetNumber: item.commnetNumber,
            contentImageURL: item.contentImageURL,
            isBlind: item.isBlind
        )
    }
}

extension MigratedDetailViewModel {
    
    func updateReplyGhostState(for memberID: Int) -> [FlattenReplyModel] {
        let updateDatas = replySubject.value.map { item in
            guard item.memberID == memberID else { return item }
            return item.editWith(
                isGhost: true,
                memberGhost: item.memberGhost - 1
            )
        }
        
        replySubject.send(updateDatas)
        return updateDatas
    }
    
    func updateReplyHeartButtonState(for commentID: Int) {
        
        let updateDatas = replySubject.value.map { item in
            guard item.commentID == commentID else { return item }
            return item.editWith(
                isLiked: !item.isLiked,
                commentLikedNumber: item.isLiked ? item.commentLikedNumber - 1 : item.commentLikedNumber + 1
            )
        }
        
        replySubject.send(updateDatas)
    }
    
    func updateFeedHeartButtonState() {
        let item = feedSubject.value ?? defalutHomeFeedDTO()
        let newData = HomeFeedDTO(
            memberID: item.memberID,
            memberProfileURL: item.memberProfileURL,
            memberNickname: item.memberNickname,
            isGhost: item.isGhost,
            memberGhost: item.memberGhost - 1,
            isLiked: !item.isLiked,
            time: item.time,
            likedNumber: item.isLiked ? item.likedNumber - 1 : item.likedNumber + 1,
            memberFanTeam: item.memberFanTeam,
            contentID: contentID,
            contentTitle: item.contentTitle,
            contentText: item.contentText,
            commentNumber: item.commentNumber,
            isDeleted: item.isDeleted,
            commnetNumber: item.commnetNumber,
            contentImageURL: item.contentImageURL,
            isBlind: item.isBlind
        )
        
        feedSubject.send(newData)
    }
    
    func updateFeedGhostState(for memberID: Int) -> HomeFeedDTO {

        let updateItem = feedSubject.value.map { item in
            guard item.memberID == memberID else { return item }
            
            return HomeFeedDTO(
                memberID: item.memberID,
                memberProfileURL: item.memberProfileURL,
                memberNickname: item.memberNickname,
                isGhost: true,
                memberGhost: item.memberGhost - 1,
                isLiked: item.isLiked,
                time: item.time,
                likedNumber: item.likedNumber,
                memberFanTeam: item.memberFanTeam,
                contentID: contentID,
                contentTitle: item.contentTitle,
                contentText: item.contentText,
                commentNumber: item.commentNumber,
                isDeleted: item.isDeleted,
                commnetNumber: item.commnetNumber,
                contentImageURL: item.contentImageURL,
                isBlind: item.isBlind
            )
        }
        
        feedSubject.send(updateItem)
        return updateItem ?? defalutHomeFeedDTO()
    }

    func defalutHomeFeedDTO() -> HomeFeedDTO {
        return HomeFeedDTO(
            memberID: -1,
            memberProfileURL: "",
            memberNickname: "",
            isGhost: false,
            memberGhost: 0,
            isLiked: false,
            time: "",
            likedNumber: 0,
            memberFanTeam: "",
            contentID: -1,
            contentTitle: "",
            contentText: "",
            commentNumber: 0,
            isDeleted: false,
            commnetNumber: 0,
            contentImageURL: nil,
            isBlind: false
        )
    }
}

