//
//  HomeViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/27/25.
//


import Combine
import Foundation

final class HomeViewModel {
    private let fetchContentListUseCase: FetchContentListUseCase
    private let createContentLikedUseCase: CreateContentLikedUseCase
    private let deleteContentLikedUseCase: DeleteContentLikedUseCase
    private let fetchUserInformationUseCase: FetchUserInformationUseCase
    private let fetchGhostUseCase: FetchGhostUseCase
    private let createReportUseCase: CreateReportUseCase
    private let createBannedUseCase: CreateBannedUseCase
    private let deleteContentUseCase: DeleteContentUseCase
    
    init(
        fetchContentListUseCase: FetchContentListUseCase,
        createContentLikedUseCase: CreateContentLikedUseCase,
        deleteContentLikedUseCase: DeleteContentLikedUseCase,
        fetchUserInformationUseCase: FetchUserInformationUseCase,
        fetchGhostUseCase: FetchGhostUseCase,
        createReportUseCase: CreateReportUseCase,
        createBannedUseCase: CreateBannedUseCase,
        deleteContentUseCase: DeleteContentUseCase
    ) {
        self.fetchContentListUseCase = fetchContentListUseCase
        self.createContentLikedUseCase = createContentLikedUseCase
        self.deleteContentLikedUseCase = deleteContentLikedUseCase
        self.fetchUserInformationUseCase = fetchUserInformationUseCase
        self.fetchGhostUseCase = fetchGhostUseCase
        self.createReportUseCase = createReportUseCase
        self.createBannedUseCase = createBannedUseCase
        self.deleteContentUseCase = deleteContentUseCase
    }
}

extension HomeViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didSelectedItem: AnyPublisher<Int, Never>
        let didHeartTappedItem: AnyPublisher<(Int, Bool), Never>
        let didGhostTappedItem: AnyPublisher<(Int, Int), Never>
        let didDeleteTappedItem: AnyPublisher<Int, Never>
        let didBannedTappedItem: AnyPublisher<(Int, Int), Never>
        let didReportTappedItem: AnyPublisher<(String, String), Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let activeUserID: AnyPublisher<Int?, Never>
        let badgeCount: AnyPublisher<Int?, Never>
        let isAdmin: AnyPublisher<Bool?, Never>
        let contents: AnyPublisher<[Content], Never>
        let selectedContent: AnyPublisher<Content, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
        let isReportSucceed: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let contentsSubject = CurrentValueSubject<[Content], Never>([])
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
        let isLastViewSubject = CurrentValueSubject<Bool, Never>(false)
        let activeUserIDSubject = CurrentValueSubject<Int?, Never>(nil)
        let isAdminSubject = CurrentValueSubject<Bool?, Never>(false)
        let isReportSucceedSubject = CurrentValueSubject<Bool, Never>(false)
        let badgeCountSubject = CurrentValueSubject<Int?, Never>(nil)
        
        let loadTrigger = Publishers.Merge(
            input.viewDidRefresh,
            input.viewWillAppear
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
            .flatMap { owner, _ -> AnyPublisher<UserSession?, Never> in
                return owner.fetchUserInformationUseCase.fetchActiveUserInfo()
                    .eraseToAnyPublisher()
            }
            .sink { info in
                isAdminSubject.send(info?.isAdmin)
                
                badgeCountSubject.send(info?.notificationBadgeCount)
            }
            .store(in: cancelBag)
        
        loadTrigger
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
                isLastViewSubject.send(false)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Content], Never> in
                return owner.fetchContentListUseCase.execute(cursor: -1)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { contents in
                isLoadingSubject.send(false)
                isLastViewSubject.send(contents.isEmpty || contents.count < Constant.defaultContentCountPerPage)
            })
            .sink { contentsSubject.send($0) }
            .store(in: cancelBag)
        
        input.willDisplayLastItem
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isLoadingMoreSubject.value && !isLastViewSubject.value && !contentsSubject.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isLoadingMoreSubject.send(true)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Content], Never> in
                guard let lastItem = contentsSubject.value.last else {
                    return .just([])
                }
                
                let cursor = lastItem.content.id
                return owner.fetchContentListUseCase.execute(cursor: cursor)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { content in
                isLoadingMoreSubject.send(false)
                isLastViewSubject.send(content.isEmpty || content.count < Constant.defaultContentCountPerPage)
            })
            .filter { !$0.isEmpty }
            .sink { content in
                var currentItems = contentsSubject.value
                currentItems.append(contentsOf: content)
                contentsSubject.send(currentItems)
            }
            .store(in: cancelBag)
        
        input.didHeartTappedItem
            .withUnretained(self)
            .flatMap { owner, info -> AnyPublisher<(Int, Bool), Never> in
                return (info.1 ? owner.createContentLikedUseCase.execute(contentID: info.0)
                        : owner.deleteContentLikedUseCase.execute(contentID: info.0))
                .map { _ in info }
                .asDriver(onErrorJustReturn: info)
            }
            .sink(receiveValue: { contentID, isLiked in
                var updatedContents = contentsSubject.value
                
                guard let index = updatedContents.firstIndex(where: { $0.content.id == contentID }) else { return }
                
                let originalContent = updatedContents[index]
                let originalUserContent = originalContent.content
                let originalContentInfo = originalUserContent.contentInfo
                let originalLike = originalContentInfo.like
                
                let updatedLike = isLiked
                ? Like(status: true, count: originalLike.count + 1)
                : Like(status: false, count: max(0, originalLike.count - 1))
                
                let updatedContent = Content(
                    content: UserContent(
                        id: originalUserContent.id,
                        contentInfo: ContentInfo(
                            author: originalContentInfo.author,
                            createdDate: originalContentInfo.createdDate,
                            title: originalContentInfo.title,
                            imageURL: originalContentInfo.imageURL,
                            text: originalContentInfo.text,
                            status: originalContentInfo.status,
                            like: updatedLike,
                            opacity: originalContentInfo.opacity,
                            commentCount: originalContentInfo.commentCount
                        )
                    ),
                    isDeleted: originalContent.isDeleted
                )
                
                updatedContents[index] = updatedContent
                contentsSubject.send(updatedContents)
            })
            .store(in: cancelBag)
        
        input.didGhostTappedItem
            .withUnretained(self)
            .flatMap { owner, id -> AnyPublisher<Int, Never> in
                return owner.fetchGhostUseCase.execute(type: .content, targetID: id.0, userID: id.1)
                    .map { _ in id.1 }
                    .asDriver(onErrorJustReturn: id.1)
            }
            .sink(receiveValue: { userID in
                var updatedContents = contentsSubject.value
                
                for i in 0..<updatedContents.count {
                    if updatedContents[i].content.contentInfo.author.id == userID {
                        let content = updatedContents[i]
                        let contentInfo = content.content.contentInfo
                        let userContent = content.content
                        let opacity = contentInfo.opacity.reduced()
                        
                        let updatedContent = Content(
                            content: UserContent(
                                id: userContent.id,
                                contentInfo: ContentInfo(
                                    author: contentInfo.author,
                                    createdDate: contentInfo.createdDate,
                                    title: contentInfo.title,
                                    imageURL: contentInfo.imageURL,
                                    text: contentInfo.text,
                                    status: .ghost,
                                    like: contentInfo.like,
                                    opacity: opacity,
                                    commentCount: contentInfo.commentCount
                                )
                            ),
                            isDeleted: content.isDeleted
                        )
                        
                        updatedContents[i] = updatedContent
                    }
                }
                
                contentsSubject.send(updatedContents)
            })
            .store(in: cancelBag)
        
        input.didDeleteTappedItem
            .withUnretained(self)
            .flatMap { owner, id -> AnyPublisher<Int, Never> in
                return owner.deleteContentUseCase.execute(contentID: id)
                    .map { _ in id }
                    .asDriver(onErrorJustReturn: id)
            }
            .compactMap { contentID in
                return contentsSubject.value.firstIndex(where: { $0.content.id == contentID })
            }
            .sink(receiveValue: { index in
                var updatedContents = contentsSubject.value
                
                updatedContents.remove(at: index)
                contentsSubject.send(updatedContents)
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
            .flatMap { owner, content -> AnyPublisher<Int, Never> in
                return owner.createBannedUseCase.execute(memberID: content.0, triggerType: .content, triggerID: content.1)
                    .map { _ in content.0 }
                    .asDriver(onErrorJustReturn: -1)
            }
            .sink(receiveValue: { userID in
                guard userID != -1 else { return }
                
                var updatedContents = contentsSubject.value
                
                for i in 0..<updatedContents.count {
                    if updatedContents[i].content.contentInfo.author.id == userID {
                        let content = updatedContents[i]
                        let contentInfo = content.content.contentInfo
                        let userContent = content.content
                        let opacity = contentInfo.opacity.reduced()
                        
                        let updatedContent = Content(
                            content: UserContent(
                                id: userContent.id,
                                contentInfo: ContentInfo(
                                    author: contentInfo.author,
                                    createdDate: contentInfo.createdDate,
                                    title: contentInfo.title,
                                    imageURL: contentInfo.imageURL,
                                    text: contentInfo.text,
                                    status: .blind,
                                    like: contentInfo.like,
                                    opacity: opacity,
                                    commentCount: contentInfo.commentCount
                                )
                            ),
                            isDeleted: content.isDeleted
                        )
                        
                        updatedContents[i] = updatedContent
                    }
                }
                
                contentsSubject.send(updatedContents)
            })
            .store(in: cancelBag)
        
        let selectedContent = input.didSelectedItem
            .filter { $0 < contentsSubject.value.count }
            .map { contentsSubject.value[$0] }
            .eraseToAnyPublisher()
        
        return Output(
            activeUserID: activeUserIDSubject.eraseToAnyPublisher(),
            badgeCount: badgeCountSubject.eraseToAnyPublisher(),
            isAdmin: isAdminSubject.eraseToAnyPublisher(),
            contents: contentsSubject.eraseToAnyPublisher(),
            selectedContent: selectedContent,
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher(),
            isReportSucceed: isReportSucceedSubject.eraseToAnyPublisher()
        )
    }
}

private extension HomeViewModel {
    enum Constant {
        static let defaultContentCountPerPage: Int = 10
        static let initialCursor: Int = -1
    }
}
