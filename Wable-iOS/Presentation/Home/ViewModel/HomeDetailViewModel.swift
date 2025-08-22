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
        let didCommentHeartTappedItem: AnyPublisher<(Bool, CommentTemp), Never>
        let didCommentTappedItem: AnyPublisher<Void, Never>
        let didReplyTappedItem: AnyPublisher<(Int, Int), Never>
        let didCreateTappedItem: AnyPublisher<String, Never>
        let didGhostTappedItem: AnyPublisher<(Int, Int, String?, PostType), Never>
        let didDeleteTappedItem: AnyPublisher<(Int, PostType), Never>
        let didBannedTappedItem: AnyPublisher<(Int, Int, TriggerType.Ban), Never>
        let didReportTappedItem: AnyPublisher<(String, String), Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let activeUserID: AnyPublisher<Int?, Never>
        let isAdmin: AnyPublisher<Bool?, Never>
        let content: AnyPublisher<ContentTemp?, Never>
        let contentNotFound: AnyPublisher<Void, Never>
        let comments: AnyPublisher<[CommentTemp], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
        let textViewState: AnyPublisher<CommentType, Never>
        let postSucceed: AnyPublisher<Bool, Never>
        let isReportSucceed: AnyPublisher<Bool, Never>
        let isContentDeleted: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let contentSubject = CurrentValueSubject<ContentTemp?, Never>(nil)
        let contentNotFoundSubject = PassthroughSubject<Void, Never>()
        let commentsSubject = CurrentValueSubject<[CommentTemp], Never>([])
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
            .flatMap({ owner, _ -> AnyPublisher<(ContentTemp?, [CommentTemp]), Never> in
                let contentPublisher = owner.fetchContentInfoUseCase.execute(contentID: owner.contentID)
                    .map { contentInfo -> ContentTemp? in
                        return contentInfo
                    }
                    .catch { error -> AnyPublisher<ContentTemp?, Never> in
                        WableLogger.log("\(error.localizedDescription)", for: .error)
                        if case WableError.notFoundContent = error {
                            contentNotFoundSubject.send()
                        }
                        return .just(nil)
                    }
                    .replaceError(with: nil)
                
                let commentsPublisher = owner.fetchContentCommentListUseCase.execute(
                    contentID: owner.contentID,
                    cursor: IntegerLiterals.initialCursor
                )
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
                
                return contentPublisher.zip(commentsPublisher)
                    .eraseToAnyPublisher()
            })
            .handleEvents(receiveOutput: { result in
                let (_, comments) = result
                
                isLoadingSubject.send(false)
                isLastViewSubject.send(comments.isEmpty || self.flattenComments(comments).count < IntegerLiterals.commentCountPerPage)
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
                
                let updatedContent = ContentTemp(
                    id: content.id,
                    author: content.author,
                    text: content.text,
                    title: content.title,
                    imageURL: content.imageURL,
                    isDeleted: content.isDeleted,
                    createdDate: content.createdDate,
                    isLiked: isLiked,
                    likeCount: isLiked ? content.likeCount + 1 : content.likeCount - 1,
                    opacity: content.opacity,
                    commentCount: content.commentCount,
                    status: content.status
                )
                
                contentSubject.send(updatedContent)
            })
            .store(in: cancelBag)
        
        input.didCommentHeartTappedItem
            .withUnretained(self)
            .flatMap { owner, info -> AnyPublisher<(Bool, CommentTemp), Never> in
                let (isLiked, comment) = info
                return (isLiked ? owner.createCommentLikedUseCase.execute(commentID: comment.id, notificationText: comment.text)
                        : owner.deleteCommentLikedUseCase.execute(commentID: comment.id))
                .map { _ in info }
                .asDriver(onErrorJustReturn: info)
            }
            .sink(receiveValue: { isLiked, commentInfo in
                var updatedComments = commentsSubject.value
                
                for i in 0..<updatedComments.count {
                    if updatedComments[i].id == commentInfo.id {
                        let originalComment = updatedComments[i]
                        
                        updatedComments[i] = CommentTemp(
                            id: originalComment.id,
                            author: originalComment.author,
                            text: originalComment.text,
                            contentID: originalComment.contentID,
                            isDeleted: originalComment.isDeleted,
                            createdDate: originalComment.createdDate,
                            parentContentID: originalComment.parentContentID,
                            children: originalComment.children,
                            likeCount: isLiked ? originalComment.likeCount + 1 : originalComment.likeCount - 1,
                            isLiked: isLiked,
                            opacity: originalComment.opacity,
                            status: originalComment.status
                        )
                        
                        commentsSubject.send(updatedComments)
                        return
                    }
                    
                    for j in 0..<updatedComments[i].children.count {
                        if updatedComments[i].children[j].id == commentInfo.id {
                            let originalChild = updatedComments[i].children[j]
                            var updatedChilds = updatedComments[i].children
                            
                            let updatedChildInfo = CommentTemp(
                                id: originalChild.id,
                                author: originalChild.author,
                                text: originalChild.text,
                                contentID: originalChild.contentID,
                                isDeleted: originalChild.isDeleted,
                                createdDate: originalChild.createdDate,
                                parentContentID: originalChild.parentContentID,
                                children: originalChild.children,
                                likeCount: isLiked ? originalChild.likeCount + 1 : originalChild.likeCount - 1,
                                isLiked: isLiked,
                                opacity: originalChild.opacity,
                                status: originalChild.status
                            )
                            
                            updatedChilds[j] = updatedChildInfo
                            
                            updatedComments[i] = CommentTemp(
                                id: updatedComments[i].id,
                                author: updatedComments[i].author,
                                text: updatedComments[i].text,
                                contentID: updatedComments[i].contentID,
                                isDeleted: updatedComments[i].isDeleted,
                                createdDate: updatedComments[i].createdDate,
                                parentContentID: updatedComments[i].parentContentID,
                                children: updatedChilds,
                                likeCount: updatedComments[i].likeCount,
                                isLiked: updatedComments[i].isLiked,
                                opacity: updatedComments[i].opacity,
                                status: updatedComments[i].status
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
                return owner.fetchGhostUseCase.execute(type: input.3, targetID: input.0, userID: input.1, reason: input.2)
                    .map { _ in input.1 }
                    .asDriver(onErrorJustReturn: input.1)
            }
            .sink(receiveValue: { [weak self] userID in
                guard let self = self,
                      let content = contentSubject.value
                else {
                    return
                }
                
                let updatedCommentInfo = updateGhostComments(comments: commentsSubject.value, userID: userID)
                
                commentsSubject.send(updatedCommentInfo)
                
                if userID == content.author.id {
                    let updatedContent = ContentTemp(
                        id: content.id,
                        author: content.author,
                        text: content.text,
                        title: content.title,
                        imageURL: content.imageURL,
                        isDeleted: content.isDeleted,
                        createdDate: content.createdDate,
                        isLiked: content.isLiked,
                        likeCount: content.likeCount,
                        opacity: content.opacity,
                        commentCount: content.commentCount,
                        status: .ghost
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
                      let content = contentSubject.value
                else {
                    return
                }
                
                let updatedCommentInfo = self.updateBannedComments(comments: commentsSubject.value, userID: userID)
                
                commentsSubject.send(updatedCommentInfo)
                
                if userID == content.author.id {
                    let updatedContent = ContentTemp(
                        id: content.id,
                        author: content.author,
                        text: content.text,
                        title: content.title,
                        imageURL: content.imageURL,
                        isDeleted: content.isDeleted,
                        createdDate: content.createdDate,
                        isLiked: content.isLiked,
                        likeCount: content.likeCount,
                        opacity: content.opacity,
                        commentCount: content.commentCount,
                        status: .blind
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
            .flatMap { owner, _ -> AnyPublisher<[CommentTemp], Never> in
                guard let lastItem = commentsSubject.value.last else { return .just([]) }
                
                let cursor = lastItem.id
                return owner.fetchContentCommentListUseCase.execute(contentID: owner.contentID, cursor: cursor)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] comments in
                guard let self = self else { return }
                
                isLoadingMoreSubject.send(false)
                isLastViewSubject.send(comments.isEmpty || self.flattenComments(comments).count < IntegerLiterals.commentCountPerPage)
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
            contentNotFound: contentNotFoundSubject.asDriver(),
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
    func updateGhostComments(comments: [CommentTemp], userID: Int) -> [CommentTemp] {
        return comments.map { comment in
            let updatedComment: CommentTemp
            
            if comment.author.id == userID {
                updatedComment = CommentTemp(
                    id: comment.id,
                    author: comment.author,
                    text: comment.text,
                    contentID: comment.contentID,
                    isDeleted: comment.isDeleted,
                    createdDate: comment.createdDate,
                    parentContentID: comment.parentContentID,
                    children: comment.children,
                    likeCount: comment.likeCount,
                    isLiked: comment.isLiked,
                    opacity: comment.opacity.reduced(),
                    status: .ghost
                )
            } else {
                updatedComment = comment
            }
            
            if !updatedComment.children.isEmpty {
                let updatedChildren = updateGhostComments(comments: updatedComment.children, userID: userID)
                
                return CommentTemp(
                    id: updatedComment.id,
                    author: updatedComment.author,
                    text: updatedComment.text,
                    contentID: updatedComment.contentID,
                    isDeleted: updatedComment.isDeleted,
                    createdDate: updatedComment.createdDate,
                    parentContentID: updatedComment.parentContentID,
                    children: updatedChildren,
                    likeCount: updatedComment.likeCount,
                    isLiked: updatedComment.isLiked,
                    opacity: updatedComment.opacity,
                    status: updatedComment.status
                )
            }
            
            return updatedComment
        }
    }
    
    func updateBannedComments(comments: [CommentTemp], userID: Int) -> [CommentTemp] {
        return comments.map { comment in
            let updatedComment: CommentTemp
            
            if comment.author.id == userID {
                updatedComment = CommentTemp(
                    id: comment.id,
                    author: comment.author,
                    text: comment.text,
                    contentID: comment.contentID,
                    isDeleted: comment.isDeleted,
                    createdDate: comment.createdDate,
                    parentContentID: comment.parentContentID,
                    children: comment.children,
                    likeCount: comment.likeCount,
                    isLiked: comment.isLiked,
                    opacity: comment.opacity.reduced(),
                    status: .blind
                )
            } else {
                updatedComment = comment
            }
            
            if !updatedComment.children.isEmpty {
                let updatedChildren = updateBannedComments(comments: updatedComment.children, userID: userID)
                
                return CommentTemp(
                    id: updatedComment.id,
                    author: updatedComment.author,
                    text: updatedComment.text,
                    contentID: updatedComment.contentID,
                    isDeleted: updatedComment.isDeleted,
                    createdDate: updatedComment.createdDate,
                    parentContentID: updatedComment.parentContentID,
                    children: updatedChildren,
                    likeCount: updatedComment.likeCount,
                    isLiked: updatedComment.isLiked,
                    opacity: updatedComment.opacity,
                    status: updatedComment.status
                )
            }
            
            return updatedComment
        }
    }
    
    func updateDeleteComments(comments: [CommentTemp], commentID: Int) -> [CommentTemp] {
        return comments.map { comment in
            let updatedComment: CommentTemp
            
            if comment.id == commentID {
                updatedComment = CommentTemp(
                    id: commentID,
                    author: comment.author,
                    text: comment.text,
                    contentID: comment.contentID,
                    isDeleted: true,
                    createdDate: comment.createdDate,
                    parentContentID: comment.parentContentID,
                    children: comment.children,
                    likeCount: comment.likeCount,
                    isLiked: comment.isLiked,
                    opacity: comment.opacity,
                    status: comment.status
                )
            } else {
                updatedComment = comment
            }

            if !updatedComment.children.isEmpty {
                let updatedChilds = updateDeleteComments(comments: updatedComment.children, commentID: commentID)
                
                return CommentTemp(
                    id: updatedComment.id,
                    author: updatedComment.author,
                    text: updatedComment.text,
                    contentID: updatedComment.contentID,
                    isDeleted: updatedComment.isDeleted,
                    createdDate: updatedComment.createdDate,
                    parentContentID: updatedComment.parentContentID,
                    children: updatedChilds,
                    likeCount: updatedComment.likeCount,
                    isLiked: updatedComment.isLiked,
                    opacity: updatedComment.opacity,
                    status: updatedComment.status
                )
            }
            
            return updatedComment
        }
    }
    
    func flattenComments(_ comments: [CommentTemp]) -> [CommentTemp] {
        var flattenedComments: [CommentTemp] = []
        
        for comment in comments {
            flattenedComments.append(comment)
            flattenedComments.append(contentsOf: comment.children)
        }
        
        return flattenedComments
    }
}
