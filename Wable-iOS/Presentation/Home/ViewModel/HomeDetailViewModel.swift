//
//  HomeDetailViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/5/25.
//


import Combine
import Foundation

final class HomeDetailViewModel {
    private let contentID: Int
    private let fetchContentInfoUseCase: FetchContentInfoUseCase
    private let fetchContentCommentListUseCase: FetchContentCommentListUseCase
    private let createCommentUseCase: CreateCommentUseCase
    private let deleteCommentUseCase: DeleteCommentUseCase
    private let createContentLikedUseCase: CreateContentLikedUseCase
    private let deleteContentLikedUseCase: DeleteContentLikedUseCase
    private let createCommentLikedUseCase: CreateCommentLikedUseCase
    private let deleteCommentLikedUseCase: DeleteCommentLikedUseCase
    private let fetchUserInformationUseCase: FetchUserInformationUseCase
    private let fetchGhostUseCase: FetchGhostUseCase
    private let createReportUseCase: CreateReportUseCase
    private let createBannedUseCase: CreateBannedUseCase
    private let deleteContentUseCase: DeleteContentUseCase
    
    init(
        contentID: Int,
        fetchContentInfoUseCase: FetchContentInfoUseCase,
        fetchContentCommentListUseCase: FetchContentCommentListUseCase,
        createCommentUseCase: CreateCommentUseCase,
        deleteCommentUseCase: DeleteCommentUseCase,
        createContentLikedUseCase: CreateContentLikedUseCase,
        deleteContentLikedUseCase: DeleteContentLikedUseCase,
        createCommentLikedUseCase: CreateCommentLikedUseCase,
        deleteCommentLikedUseCase: DeleteCommentLikedUseCase,
        fetchUserInformationUseCase: FetchUserInformationUseCase,
        fetchGhostUseCase: FetchGhostUseCase,
        createReportUseCase: CreateReportUseCase,
        createBannedUseCase: CreateBannedUseCase,
        deleteContentUseCase: DeleteContentUseCase
    ) {
        self.contentID = contentID
        self.fetchContentInfoUseCase = fetchContentInfoUseCase
        self.fetchContentCommentListUseCase = fetchContentCommentListUseCase
        self.createCommentUseCase = createCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.createContentLikedUseCase = createContentLikedUseCase
        self.deleteContentLikedUseCase = deleteContentLikedUseCase
        self.createCommentLikedUseCase = createCommentLikedUseCase
        self.deleteCommentLikedUseCase = deleteCommentLikedUseCase
        self.fetchUserInformationUseCase = fetchUserInformationUseCase
        self.fetchGhostUseCase = fetchGhostUseCase
        self.createReportUseCase = createReportUseCase
        self.createBannedUseCase = createBannedUseCase
        self.deleteContentUseCase = deleteContentUseCase
    }
}

extension HomeDetailViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didContentHeartTappedItem: AnyPublisher<Bool, Never>
        let didCommentHeartTappedItem: AnyPublisher<(Bool, ContentComment), Never>
        let didCommentTappedItem: AnyPublisher<Void, Never>
        let didReplyTappedItem: AnyPublisher<(Int, Int), Never>
        let didCreateTappedItem: AnyPublisher<String, Never>
        let didGhostTappedItem: AnyPublisher<(Int, Int, PostType), Never>
        let didDeleteTappedItem: AnyPublisher<(Int, PostType), Never>
        let didBannedTappedItem: AnyPublisher<(Int, Int, TriggerType.Ban), Never>
        let didReportTappedItem: AnyPublisher<(String, String), Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let activeUserID: AnyPublisher<Int?, Never>
        let isAdmin: AnyPublisher<Bool?, Never>
        let content: AnyPublisher<ContentInfo?, Never>
        let comments: AnyPublisher<[ContentComment], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
        let textViewState: AnyPublisher<CommentType, Never>
        let postSucceed: AnyPublisher<Bool, Never>
        let isReportSucceed: AnyPublisher<Bool, Never>
        let isContentDeleted: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let contentSubject = CurrentValueSubject<ContentInfo?, Never>(nil)
        let commentsSubject = CurrentValueSubject<[ContentComment], Never>([])
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
        let isLastViewSubject = CurrentValueSubject<Bool, Never>(false)
        let replyParentSubject = CurrentValueSubject<(Int, Int), Never>((-1, -1))
        let commentTypeSubject = CurrentValueSubject<CommentType, Never>(.ripple)
        let postSucceedSubject = CurrentValueSubject<Bool, Never>(false)
        let activeUserIDSubject = CurrentValueSubject<Int?, Never>(nil)
        let isAdminSubject = CurrentValueSubject<Bool?, Never>(false)
        let isReportSucceedSubject = CurrentValueSubject<Bool, Never>(false)
        let isContentDeletedSubject = CurrentValueSubject<Bool, Never>(false)
        
        let refreshTriggerSubject = PassthroughSubject<Void, Never>()
        
        let loadTrigger = Publishers.Merge3(
            input.viewDidRefresh,
            input.viewWillAppear,
            refreshTriggerSubject
        )
        
        loadTrigger
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Int?, Never> in
                return owner.fetchUserInformationUseCase.fetchActiveUserID()
            }
            .sink { userID in
                activeUserIDSubject.send(userID)
            }
            .store(in: cancelBag)
        
        loadTrigger
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Bool?, Never> in
                return owner.fetchUserInformationUseCase.fetchActiveUserInfo()
                    .map { info in info?.isAdmin }
                    .eraseToAnyPublisher()
            }
            .sink { isAdmin in
                isAdminSubject.send(isAdmin)
            }
            .store(in: cancelBag)
        
        loadTrigger
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
                isLastViewSubject.send(false)
            })
            .withUnretained(self)
            .flatMap({ owner, _ -> AnyPublisher<(ContentInfo?, [ContentComment]), Never> in
                let contentPublisher = owner.fetchContentInfoUseCase.execute(contentID: owner.contentID)
                    .map { contentInfo -> ContentInfo? in
                        return contentInfo
                    }
                    .replaceError(with: nil)
                
                let commentsPublisher = owner.fetchContentCommentListUseCase.execute(
                    contentID: owner.contentID,
                    cursor: Constant.initialCursor
                )
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
                
                return contentPublisher.zip(commentsPublisher)
                    .eraseToAnyPublisher()
            })
            .handleEvents(receiveOutput: { result in
                isLoadingSubject.send(false)
                isLastViewSubject.send(result.1.isEmpty)
            })
            .sink { result in
                contentSubject.send(result.0)
                commentsSubject.send(result.1)
            }
            .store(in: cancelBag)
        
        input.didContentHeartTappedItem
            .withUnretained(self)
            .flatMap { owner, isLiked -> AnyPublisher<Bool, Never> in
                return (isLiked ? owner.createContentLikedUseCase.execute(contentID: owner.contentID)
                        : owner.deleteContentLikedUseCase.execute(contentID: owner.contentID))
                .map { _ in isLiked }
                .asDriver(onErrorJustReturn: isLiked)
            }
            .sink(receiveValue: { isLiked in
                guard let content = contentSubject.value else { return }
                
                let originalLike = content.like
                let updatedLike = isLiked
                ? Like(status: true, count: originalLike.count + 1)
                : Like(status: false, count: max(0, originalLike.count - 1))
                
                let updatedContent = ContentInfo(
                    author: content.author,
                    createdDate: content.createdDate,
                    title: content.title,
                    imageURL: content.imageURL,
                    text: content.text,
                    status: content.status,
                    like: updatedLike,
                    opacity: content.opacity,
                    commentCount: content.commentCount
                )
                
                contentSubject.send(updatedContent)
            })
            .store(in: cancelBag)
        
        input.didCommentHeartTappedItem
            .withUnretained(self)
            .flatMap { owner, info -> AnyPublisher<(Bool, ContentComment), Never> in
                let (isLiked, comment) = info
                return (isLiked ? owner.createCommentLikedUseCase.execute(commentID: comment.comment.id, notificationText: comment.comment.text)
                        : owner.deleteCommentLikedUseCase.execute(commentID: comment.comment.id))
                .map { _ in info }
                .asDriver(onErrorJustReturn: info)
            }
            .sink(receiveValue: { isLiked, commentInfo in
                var updatedComments = commentsSubject.value
                
                for i in 0..<updatedComments.count {
                    if updatedComments[i].comment.id == commentInfo.comment.id {
                        let originalComment = updatedComments[i].comment
                        let originalLike = originalComment.like
                        
                        let updatedLike = isLiked
                        ? Like(status: true, count: originalLike.count + 1)
                        : Like(status: false, count: max(0, originalLike.count - 1))
                        
                        let updatedCommentInfo = CommentInfo(
                            author: originalComment.author,
                            id: originalComment.id,
                            text: originalComment.text,
                            createdDate: originalComment.createdDate,
                            status: originalComment.status,
                            like: updatedLike,
                            opacity: originalComment.opacity
                        )
                        
                        updatedComments[i] = ContentComment(
                            comment: updatedCommentInfo,
                            parentID: updatedComments[i].parentID,
                            isDeleted: updatedComments[i].isDeleted,
                            childs: updatedComments[i].childs
                        )
                        
                        commentsSubject.send(updatedComments)
                        return
                    }
                    
                    for j in 0..<updatedComments[i].childs.count {
                        if updatedComments[i].childs[j].comment.id == commentInfo.comment.id {
                            let originalChild = updatedComments[i].childs[j].comment
                            let originalLike = originalChild.like
                            
                            let updatedLike = isLiked
                            ? Like(status: true, count: originalLike.count + 1)
                            : Like(status: false, count: max(0, originalLike.count - 1))
                            
                            let updatedChildInfo = CommentInfo(
                                author: originalChild.author,
                                id: originalChild.id,
                                text: originalChild.text,
                                createdDate: originalChild.createdDate,
                                status: originalChild.status,
                                like: updatedLike,
                                opacity: originalChild.opacity
                            )
                            
                            var updatedChilds = updatedComments[i].childs
                            updatedChilds[j] = ContentComment(
                                comment: updatedChildInfo,
                                parentID: updatedChilds[j].parentID,
                                isDeleted: updatedChilds[j].isDeleted,
                                childs: updatedChilds[j].childs
                            )
                            
                            updatedComments[i] = ContentComment(
                                comment: updatedComments[i].comment,
                                parentID: updatedComments[i].parentID,
                                isDeleted: updatedComments[i].isDeleted,
                                childs: updatedChilds
                            )
                            
                            commentsSubject.send(updatedComments)
                            return
                        }
                    }
                }
            })
            .store(in: cancelBag)
        
        input.didCommentTappedItem
            .withUnretained(self)
            .sink { owner, _ in
                replyParentSubject.send((-1, -1))
                commentTypeSubject.send(.ripple)
            }
            .store(in: cancelBag)
        
        input.didReplyTappedItem
            .withUnretained(self)
            .sink { owner, index in
                let (commentID, authorID) = index
                
                replyParentSubject.send((commentID, authorID))
                commentTypeSubject.send(.reply)
            }
            .store(in: cancelBag)
        
        input.didGhostTappedItem
            .withUnretained(self)
            .flatMap { owner, input -> AnyPublisher<Int, Never> in
                return owner.fetchGhostUseCase.execute(type: input.2, targetID: input.0, userID: input.1)
                    .map { _ in input.1 }
                    .asDriver(onErrorJustReturn: input.1)
            }
            .sink(receiveValue: { [weak self] userID in
                guard let self = self,
                      let contentInfo = contentSubject.value
                else {
                    return
                }
                
                let updatedCommentInfo = updateGhostComments(comments: commentsSubject.value, userID: userID)
                
                commentsSubject.send(updatedCommentInfo)
                
                if userID == contentInfo.author.id {
                    let updatedContent = ContentInfo(
                        author: contentInfo.author,
                        createdDate: contentInfo.createdDate,
                        title: contentInfo.title,
                        imageURL: contentInfo.imageURL,
                        text: contentInfo.text,
                        status: .ghost,
                        like: contentInfo.like,
                        opacity: contentInfo.opacity.reduced(),
                        commentCount: contentInfo.commentCount
                    )
                    
                    contentSubject.send(updatedContent)
                }
            })
            .store(in: cancelBag)
        
        input.didReportTappedItem
            .withUnretained(self)
            .flatMap { owner, content -> AnyPublisher<Void, Never> in
                return owner.createReportUseCase.execute(nickname: content.0, text: content.1)
                    .asDriver(onErrorJustReturn: ())
            }
            .sink(receiveValue: { _ in
                isReportSucceedSubject.send(true)
            })
            .store(in: cancelBag)
        
        input.didBannedTappedItem
            .withUnretained(self)
            .flatMap { owner, input -> AnyPublisher<Int, Never> in
                return owner.createBannedUseCase.execute(memberID: input.0, triggerType: input.2, triggerID: input.1)
                    .map { _ in input.0 }
                    .asDriver(onErrorJustReturn: -1)
            }
            .sink(receiveValue: { [weak self] userID in
                guard let self = self,
                      let contentInfo = contentSubject.value
                else {
                    return
                }
                
                let updatedCommentInfo = self.updateBannedComments(comments: commentsSubject.value, userID: userID)
                
                commentsSubject.send(updatedCommentInfo)
                
                if userID == contentInfo.author.id {
                    let updatedContent = ContentInfo(
                        author: contentInfo.author,
                        createdDate: contentInfo.createdDate,
                        title: contentInfo.title,
                        imageURL: contentInfo.imageURL,
                        text: contentInfo.text,
                        status: .blind,
                        like: contentInfo.like,
                        opacity: contentInfo.opacity.reduced(),
                        commentCount: contentInfo.commentCount
                    )
                    
                    contentSubject.send(updatedContent)
                }
            })
            .store(in: cancelBag)
        
        input.didDeleteTappedItem
            .withUnretained(self)
            .flatMap { owner, input -> AnyPublisher<(Int, PostType), Never> in
                let (commentID, postType) = input
                if postType == .content {
                    return owner.deleteContentUseCase.execute(contentID: self.contentID)
                        .map { _ in input }
                        .asDriver(onErrorJustReturn: input)
                } else {
                    return owner.deleteCommentUseCase.execute(commentID: commentID)
                        .map { _ in input }
                        .asDriver(onErrorJustReturn: input)
                }
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, value in
                let (id, postType) = value
                
                if postType == .content {
                    isContentDeletedSubject.send(true)
                } else {
                    let updatedCommentInfo = owner.updateDeleteComments(
                        comments: commentsSubject.value,
                        commentID: id
                    )
                    
                    commentsSubject.send(updatedCommentInfo)
                }
            })
            .store(in: cancelBag)
        
        
        input.didCreateTappedItem
            .withUnretained(self)
            .flatMap { owner, text -> AnyPublisher<Void, Never> in
                return owner.createCommentUseCase.execute(
                    contentID: owner.contentID,
                    text: text,
                    parentID: replyParentSubject.value.0,
                    parentMemberID: replyParentSubject.value.1
                )
                .asDriver(onErrorJustReturn: ())
            }
            .sink(receiveValue: { [weak self] _ in
                guard let id = self?.contentID else { return }
                
                isLastViewSubject.send(false)
                
                self?.fetchContentCommentListUseCase.execute(contentID: id, cursor: -1)
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { comments in
                        commentsSubject.send(comments)
                    })
                    .store(in: cancelBag)
                
                self?.fetchContentInfoUseCase.execute(contentID: id)
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { content in
                        contentSubject.send(content)
                    })
                    .store(in: cancelBag)
                
                replyParentSubject.send((-1, -1))
                commentTypeSubject.send(.ripple)
                
                postSucceedSubject.send(true)
            })
            .store(in: cancelBag)
        
        input.willDisplayLastItem
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isLoadingMoreSubject.value && !isLastViewSubject.value && !commentsSubject.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isLoadingMoreSubject.send(true)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[ContentComment], Never> in
                guard let lastItem = commentsSubject.value.last else {
                    return .just([])
                }
                
                let cursor = lastItem.comment.id
                return owner.fetchContentCommentListUseCase.execute(contentID: owner.contentID, cursor: cursor)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { comments in
                isLoadingMoreSubject.send(false)
                isLastViewSubject.send(comments.isEmpty)
            })
            .filter { !$0.isEmpty }
            .sink { comment in
                var currentItems = commentsSubject.value
                currentItems.append(contentsOf: comment)
                commentsSubject.send(currentItems)
            }
            .store(in: cancelBag)
        
        return Output(
            activeUserID: activeUserIDSubject.eraseToAnyPublisher(),
            isAdmin: isAdminSubject.eraseToAnyPublisher(),
            content: contentSubject.eraseToAnyPublisher(),
            comments: commentsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher(),
            textViewState: commentTypeSubject.eraseToAnyPublisher(),
            postSucceed: postSucceedSubject.eraseToAnyPublisher(),
            isReportSucceed: isReportSucceedSubject.eraseToAnyPublisher(),
            isContentDeleted: isContentDeletedSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension HomeDetailViewModel {
    func updateGhostComments(comments: [ContentComment], userID: Int) -> [ContentComment] {
        return comments.map { comment in
            let updatedComment: ContentComment
            
            if comment.comment.author.id == userID {
                updatedComment = ContentComment(
                    comment: CommentInfo(
                        author: comment.comment.author,
                        id: comment.comment.id,
                        text: comment.comment.text,
                        createdDate: comment.comment.createdDate,
                        status: .ghost,
                        like: comment.comment.like,
                        opacity: comment.comment.opacity.reduced()
                    ),
                    parentID: comment.parentID,
                    isDeleted: comment.isDeleted,
                    childs: comment.childs
                )
            } else {
                updatedComment = comment
            }
            
            if !updatedComment.childs.isEmpty {
                let updatedChilds = updateGhostComments(comments: updatedComment.childs, userID: userID)
                
                return ContentComment(
                    comment: updatedComment.comment,
                    parentID: updatedComment.parentID,
                    isDeleted: updatedComment.isDeleted,
                    childs: updatedChilds
                )
            }
            
            return updatedComment
        }
    }
    
    func updateBannedComments(comments: [ContentComment], userID: Int) -> [ContentComment] {
        return comments.map { comment in
            let updatedComment: ContentComment
            
            if comment.comment.author.id == userID {
                updatedComment = ContentComment(
                    comment: CommentInfo(
                        author: comment.comment.author,
                        id: comment.comment.id,
                        text: comment.comment.text,
                        createdDate: comment.comment.createdDate,
                        status: .blind,
                        like: comment.comment.like,
                        opacity: comment.comment.opacity.reduced()
                    ),
                    parentID: comment.parentID,
                    isDeleted: comment.isDeleted,
                    childs: comment.childs
                )
            } else {
                updatedComment = comment
            }
            
            if !updatedComment.childs.isEmpty {
                let updatedChilds = updateBannedComments(comments: updatedComment.childs, userID: userID)
                
                return ContentComment(
                    comment: updatedComment.comment,
                    parentID: updatedComment.parentID,
                    isDeleted: updatedComment.isDeleted,
                    childs: updatedChilds
                )
            }
            
            return updatedComment
        }
    }
    
    func updateDeleteComments(comments: [ContentComment], commentID: Int) -> [ContentComment] {
        return comments.map { comment in
            let updatedComment: ContentComment
            
            if comment.comment.id == commentID {
                updatedComment = ContentComment(
                    comment: comment.comment,
                    parentID: comment.parentID,
                    isDeleted: true,
                    childs: comment.childs
                )
            } else {
                updatedComment = comment
            }

            if !updatedComment.childs.isEmpty {
                let updatedChilds = updateDeleteComments(comments: updatedComment.childs, commentID: commentID)
                
                return ContentComment(
                    comment: updatedComment.comment,
                    parentID: updatedComment.parentID,
                    isDeleted: updatedComment.isDeleted,
                    childs: updatedChilds
                )
            }
            
            return updatedComment
        }
    }
}

private extension HomeDetailViewModel {
    enum Constant {
        static let defaultContentCountPerPage: Int = 15
        static let initialCursor: Int = -1
    }
}
