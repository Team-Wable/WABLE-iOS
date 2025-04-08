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
    private let contentTitle: String
    private let fetchContentInfoUseCase: FetchContentInfoUseCase
    private let createContentLikedUseCase: CreateContentLikedUseCase
    private let deleteContentLikedUseCase: DeleteContentLikedUseCase
    private let fetchContentCommentListUseCase: FetchContentCommentListUseCase
    private let createCommentUseCase: CreateCommentUseCase
    private let deleteCommentUseCase: DeleteCommentUseCase
    private let createCommentLikedUseCase: CreateCommentLikedUseCase
    private let deleteCommentLikedUseCase: DeleteCommentLikedUseCase
    
    init(
        contentID: Int,
        contentTitle: String,
        fetchContentInfoUseCase: FetchContentInfoUseCase,
        createContentLikedUseCase: CreateContentLikedUseCase,
        deleteContentLikedUseCase: DeleteContentLikedUseCase,
        fetchContentCommentListUseCase: FetchContentCommentListUseCase,
        createCommentUseCase: CreateCommentUseCase,
        deleteCommentUseCase: DeleteCommentUseCase,
        createCommentLikedUseCase: CreateCommentLikedUseCase,
        deleteCommentLikedUseCase: DeleteCommentLikedUseCase
    ) {
        self.contentID = contentID
        self.contentTitle = contentTitle
        self.fetchContentInfoUseCase = fetchContentInfoUseCase
        self.createContentLikedUseCase = createContentLikedUseCase
        self.deleteContentLikedUseCase = deleteContentLikedUseCase
        self.fetchContentCommentListUseCase = fetchContentCommentListUseCase
        self.createCommentUseCase = createCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.createCommentLikedUseCase = createCommentLikedUseCase
        self.deleteCommentLikedUseCase = deleteCommentLikedUseCase
    }
}

extension HomeDetailViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didContentHeartTappedItem: AnyPublisher<Bool, Never>
        let didReplyTappedItem: AnyPublisher<Void, Never>
        let didCreateTappedItem: AnyPublisher<(String, Int?, Int?), Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let content: AnyPublisher<ContentInfo?, Never>
        let comments: AnyPublisher<[ContentComment], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let contentSubject = CurrentValueSubject<ContentInfo?, Never>(nil)
        let commentsSubject = CurrentValueSubject<[ContentComment], Never>([])
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
        let isLastViewSubject = CurrentValueSubject<Bool, Never>(false)
        
        Publishers.Merge<AnyPublisher<Void, Never>, AnyPublisher<Void, Never>>(
            input.viewWillAppear,
            input.viewDidRefresh
        )
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
                isLastViewSubject.send(false)
            })
            .withUnretained(self)
            .flatMap({ owner, _ -> AnyPublisher<(ContentInfo?, [ContentComment]), Never> in
                let contentPublisher = owner.fetchContentInfoUseCase.execute(
                    contentID: owner.contentID,
                    title: owner.contentTitle
                )
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
                isLastViewSubject.send(result.1.isEmpty || result.1.count < Constant.defaultContentCountPerPage)
            })
            .sink { result in
                contentSubject.send(result.0)
                commentsSubject.send(result.1)
            }
            .store(in: cancelBag)
        
        input.didContentHeartTappedItem
            .withUnretained(self)
            .flatMap { owner, info -> AnyPublisher<Void, Never> in
                if info {
                    return owner.createContentLikedUseCase.execute(contentID: owner.contentID)
                        .asDriver(onErrorJustReturn: ())
                } else {
                    return owner.deleteContentLikedUseCase.execute(contentID: owner.contentID)
                        .asDriver(onErrorJustReturn: ())
                }
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)
        
        input.didCreateTappedItem
            .withUnretained(self)
            .flatMap { owner, info -> AnyPublisher<Void, Never> in
                return owner.createCommentUseCase.execute(
                    contentID: owner.contentID,
                    text: info.0,
                    parentID: info.1,
                    parentMemberID: info.2
                )
                .asDriver(onErrorJustReturn: ())
            }
            .sink(receiveValue: { _ in })
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
            .handleEvents(receiveOutput: { content in
                isLoadingMoreSubject.send(false)
                isLastViewSubject.send(content.isEmpty || content.count < Constant.defaultContentCountPerPage)
            })
            .filter { !$0.isEmpty }
            .sink { comment in
                var currentItems = commentsSubject.value
                currentItems.append(contentsOf: comment)
                commentsSubject.send(currentItems)
            }
            .store(in: cancelBag)
        
        return Output(
            content: contentSubject.eraseToAnyPublisher(),
            comments: commentsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher()
        )
    }
}

private extension HomeDetailViewModel {
    enum Constant {
        static let defaultContentCountPerPage: Int = 10
        static let initialCursor: Int = -1
    }
}
