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
    
    init(
        fetchContentListUseCase: FetchContentListUseCase,
        createContentLikedUseCase: CreateContentLikedUseCase,
        deleteContentLikedUseCase: DeleteContentLikedUseCase
    ) {
        self.fetchContentListUseCase = fetchContentListUseCase
        self.createContentLikedUseCase = createContentLikedUseCase
        self.deleteContentLikedUseCase = deleteContentLikedUseCase
    }
}

extension HomeViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
        let didSelectedItem: AnyPublisher<Int, Never>
        let didHeartTappedItem: AnyPublisher<(Int, Bool), Never>
        let willDisplayLastItem: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let contents: AnyPublisher<[Content], Never>
        let selectedContent: AnyPublisher<Content, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let contentsSubject = CurrentValueSubject<[Content], Never>([])
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
        let isLastViewSubject = CurrentValueSubject<Bool, Never>(false)
        
        let loadTrigger = Publishers.Merge(
            input.viewDidRefresh,
            input.viewWillAppear
        )
        
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
            })
            .store(in: cancelBag)

        let selectedContent = input.didSelectedItem
            .filter { $0 < contentsSubject.value.count }
            .map { contentsSubject.value[$0] }
            .eraseToAnyPublisher()
        
        return Output(
            contents: contentsSubject.eraseToAnyPublisher(),
            selectedContent: selectedContent,
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher()
        )
    }
}

private extension HomeViewModel {
    enum Constant {
        static let defaultContentCountPerPage: Int = 10
        static let initialCursor: Int = -1
    }
}
