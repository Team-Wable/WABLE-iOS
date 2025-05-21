//
//  OtherProfileViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/20/25.
//

import Combine
import Foundation

final class OtherProfileViewModel {
    @Published private(set) var nickname: String?
    @Published private(set) var item = ProfileViewItem()
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var errorMessage: String?
    
    private var isLastPageForContent = false
    private var isLastPageForComment = false
    private var loadingMoreTask: Task<Void, Never>?
    
    private let userID: Int
    private let fetchUserProfileUseCase: FetchUserProfileUseCase
    private let fetchUserContentListUseCase: FetchUserContentListUseCase
    private let fetchUserCommentListUseCase: FetchUserCommentListUseCase
    private let selectedIndexSubject = PassthroughSubject<Int, Never>()
    private let willLastDisplaySubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    
    init(
        userID: Int,
        fetchUserProfileUseCase: FetchUserProfileUseCase,
        fetchUserContentListUseCase: FetchUserContentListUseCase,
        fetchUserCommentListUseCase: FetchUserCommentListUseCase
    ) {
        self.userID = userID
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchUserContentListUseCase = fetchUserContentListUseCase
        self.fetchUserCommentListUseCase = fetchUserCommentListUseCase
        
        bind()
    }
    
    func viewDidLoad() {
        fetchViewItems(userID: userID, segment: .content)
    }
    
    func viewDidRefresh() {
        fetchViewItems(userID: userID, segment: item.currentSegment)
    }
    
    func selectedIndexDidChange(_ selectedIndex: Int) {
        selectedIndexSubject.send(selectedIndex)
    }
    
    func didSelect(index: Int) -> Int {
        let contentID: Int
        switch item.currentSegment {
        case .content:
            contentID = item.contentList[index].id
        case .comment:
            contentID = item.commentList[index].contentID
        }
        return contentID
    }
    
    func willDisplayLast() {
        willLastDisplaySubject.send()
    }
}

private extension OtherProfileViewModel {
    func bind() {
        selectedIndexSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { return ProfileSegmentKind(rawValue: $0) }
            .sink { [weak self] in self?.item.currentSegment = $0 }
            .store(in: cancelBag)
        
        willLastDisplaySubject
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                switch item.currentSegment {
                case .content:
                    guard let lastContentID = item.contentList.last?.id else { return }
                    fetchMoreContentList(userID: userID, lastContentID: lastContentID)
                case .comment:
                    guard let lastCommentID = item.commentList.last?.comment.id else { return }
                    fetchMoreCommentList(userID: userID, lastCommentID: lastCommentID)
                }
            }
            .store(in: cancelBag)
    }
    
    func fetchViewItems(userID: Int, segment: ProfileSegmentKind) {
        isLoading = true
        
        Task {
            async let userProfile: UserProfile = fetchUserProfileUseCase.execute(userID: userID)
            async let contentList: [UserContent] = fetchUserContentListUseCase.execute(for: userID, last: Constant.initialCursor)
            async let commentList: [UserComment] = fetchUserCommentListUseCase.execute(for: userID, last: Constant.initialCursor)
            
            do {
                let (userProfile, contentList, commentList) = try await (userProfile, contentList, commentList)
                
                isLastPageForContent = contentList.count < Constant.defaultCountForContentPage
                isLastPageForComment = commentList.count < Constant.defaultCountForCommentPage
                
                nickname = userProfile.user.nickname
                
                item = ProfileViewItem(
                    currentSegment: segment,
                    profileInfo: userProfile,
                    contentList: contentList,
                    commentList: commentList
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func fetchMoreContentList(userID: Int, lastContentID: Int) {
        if isLastPageForContent || isLoadingMore { return }
        
        loadingMoreTask?.cancel()
        isLoadingMore = true
        loadingMoreTask = Task {
            do {
                let contentListForNextPage = try await fetchUserContentListUseCase.execute(for: userID, last: lastContentID)
                guard !Task.isCancelled else { return }
                isLastPageForContent = contentListForNextPage.count < Constant.defaultCountForContentPage
                item.contentList.append(contentsOf: contentListForNextPage)
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
            isLoadingMore = false
        }
    }
    
    func fetchMoreCommentList(userID: Int, lastCommentID: Int) {
        if isLastPageForComment || isLoadingMore { return }
        
        loadingMoreTask?.cancel()
        isLoadingMore = true
        loadingMoreTask = Task {
            do {
                let commentListForNextPage = try await fetchUserCommentListUseCase.execute(for: userID, last: lastCommentID)
                guard !Task.isCancelled else { return }
                isLastPageForComment = commentListForNextPage.count < Constant.defaultCountForCommentPage
                item.commentList.append(contentsOf: commentListForNextPage)
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
            
            isLoadingMore = false
        }
    }
    
    enum Constant {
        static let initialCursor = -1
        static let defaultCountForContentPage = 15
        static let defaultCountForCommentPage = 10
    }
}
