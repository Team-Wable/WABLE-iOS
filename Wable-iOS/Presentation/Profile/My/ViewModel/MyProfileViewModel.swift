//
//  MyProfileViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

final class MyProfileViewModel {
    @Published private(set) var nickname: String?
    @Published private(set) var item = ProfileViewItem()
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var errorMessage: String?
    
    private var isLastPageForContent = false
    private var isLastPageForComment = false
    private var loadingMoreTask: Task<Void, Never>?
    
    private let userID: Int?
    private let userSessionUseCase: FetchUserInformationUseCase
    private let fetchUserProfileUseCase: FetchUserProfileUseCase
    private let fetchUserCommentListUseCase: FetchUserCommentListUseCase
    private let fetchUserContentListUseCase: FetchUserContentListUseCase
    private let removeUserSessionUseCase: RemoveUserSessionUseCase
    
    private let selectedIndexSubject = PassthroughSubject<Int, Never>()
    private let willDisplaySubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    
    init(
        userinformationUseCase: FetchUserInformationUseCase,
        fetchUserProfileUseCase: FetchUserProfileUseCase,
        fetchUserCommentListUseCase: FetchUserCommentListUseCase,
        fetchUserContentListUseCase: FetchUserContentListUseCase,
        removeUserSessionUseCase: RemoveUserSessionUseCase
    ) {
        self.userSessionUseCase = userinformationUseCase
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchUserCommentListUseCase = fetchUserCommentListUseCase
        self.fetchUserContentListUseCase = fetchUserContentListUseCase
        self.removeUserSessionUseCase = removeUserSessionUseCase
        
        self.userID = userinformationUseCase.fetchActiveUserID()
        
        bind()
    }
    
    func viewDidLoad() {
        guard let userID else {
            return WableLogger.log("유저 아이디를 알 수 없음.", for: .debug)
        }
        fetchViewItems(userID: userID, segment: .content)
    }
    
    func viewDidRefresh() {
        guard let userID else {
            return WableLogger.log("유저 아이디를 알 수 없음.", for: .debug)
        }
        fetchViewItems(userID: userID, segment: item.currentSegment)
    }
    
    func selectedIndexDidChange(_ selectedIndex: Int) {
        selectedIndexSubject.send(selectedIndex)
    }
    
    func logoutDidTap() {
        removeUserSessionUseCase.removeUserSession()
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
        willDisplaySubject.send()
    }
}

private extension MyProfileViewModel {
    func bind() {
        selectedIndexSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { return ProfileSegmentKind(rawValue: $0) }
            .sink { [weak self] segment in
                self?.item.currentSegment = segment
            }
            .store(in: cancelBag)
        
        willDisplaySubject
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .compactMap { [weak self] in
                return self?.userID
            }
            .sink { [weak self] userID in
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
