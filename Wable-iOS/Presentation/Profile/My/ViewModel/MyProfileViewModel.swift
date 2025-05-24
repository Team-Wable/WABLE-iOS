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
    private let removeUserSessionUseCase: RemoveUserSessionUseCase
    @Injected private var contentRepository: ContentRepository
    @Injected private var commentRepository: CommentRepository
    @Injected private var contentLikedRepository: ContentLikedRepository
    @Injected private var commentLikedRepository: CommentLikedRepository
    
    init(
        userinformationUseCase: FetchUserInformationUseCase,
        fetchUserProfileUseCase: FetchUserProfileUseCase,
        removeUserSessionUseCase: RemoveUserSessionUseCase
    ) {
        self.userSessionUseCase = userinformationUseCase
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.removeUserSessionUseCase = removeUserSessionUseCase
        
        self.userID = userinformationUseCase.fetchActiveUserID()
    }
    
    func viewDidRefresh() {
        guard let userID else {
            return WableLogger.log("유저 아이디를 알 수 없음.", for: .debug)
        }
        fetchViewItems(userID: userID, segment: item.currentSegment)
    }
    
    func selectedIndexDidChange(_ selectedIndex: Int) {
        guard let segment = ProfileSegment(rawValue: selectedIndex) else { return }
        item.currentSegment = segment
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
        guard let userID else { return }
        
        switch item.currentSegment {
        case .content:
            guard let lastContentID = item.contentList.last?.id else { return }
            fetchMoreContentList(userID: userID, lastContentID: lastContentID)
        case .comment:
            guard let lastCommentID = item.commentList.last?.comment.id else { return }
            fetchMoreCommentList(userID: userID, lastCommentID: lastCommentID)
        }
    }
    
    func deleteContent(for contentID: Int) {
        Task {
            do {
                try await contentRepository.deleteContent(contentID: contentID)
                guard let index = item.contentList.firstIndex(where: { $0.id == contentID }) else { return }
                _ = await MainActor.run { item.contentList.remove(at: index) }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func deleteComment(for commentID: Int) {
        Task {
            do {
                try await commentRepository.deleteComment(commentID: commentID)
                guard let index = item.commentList.firstIndex(where: { $0.comment.id == commentID }) else { return }
                _ = await MainActor.run { item.commentList.remove(at: index) }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func toggleLikeContent(for contentID: Int) {
        guard let index = item.contentList.firstIndex(where: { $0.id == contentID }) else { return }
        let isLiked = item.contentList[index].contentInfo.like.status
        Task {
            do {
                isLiked
                ? try await contentLikedRepository.deleteContentLiked(contentID: contentID)
                : try await contentLikedRepository.createContentLiked(
                    contentID: contentID,
                    triggerType: TriggerType.Like.contentLike.rawValue
                )
                
                await MainActor.run {
                    var contentInfo = item.contentList[index].contentInfo
                    isLiked ? contentInfo.like.unlike() : contentInfo.like.like()
                    item.contentList[index] = UserContent(id: contentID, contentInfo: contentInfo)
                }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func toggleLikeComment(for commentID: Int) {
        guard let index = item.commentList.firstIndex(where: { $0.comment.id == commentID }) else { return }
        let comment = item.commentList[index]
        let isLiked = item.commentList[index].comment.like.status
        
        Task {
            do {
                isLiked
                ? try await commentLikedRepository.deleteCommentLiked(commentID: commentID)
                : try await commentLikedRepository.createCommentLiked(
                    commentID: commentID,
                    triggerType: TriggerType.Like.commentLike.rawValue,
                    notificationText: item.commentList[index].comment.text
                )
                
                await MainActor.run {
                    var commentInfo = comment.comment
                    isLiked ? commentInfo.like.unlike() : commentInfo.like.like()
                    item.commentList[index] = UserComment(comment: commentInfo, contentID: comment.contentID)
                }
            } catch {
                await handleError(error: error)
            }
        }
    }
}

private extension MyProfileViewModel {
    func fetchViewItems(userID: Int, segment: ProfileSegment) {
        isLoading = true
        
        Task {
            async let userProfile: UserProfile = fetchUserProfileUseCase.execute(userID: userID)

            async let contentList: [UserContent] = contentRepository.fetchUserContentList(
                memberID: userID,
                cursor: Constant.initialCursor
            )
            
            async let commentList: [UserComment] = commentRepository.fetchUserCommentList(
                memberID: userID,
                cursor: Constant.initialCursor
            )
            
            do {
                let (userProfile, contentList, commentList) = try await (userProfile, contentList, commentList)
                
                await MainActor.run {
                    isLastPageForContent = contentList.count < Constant.defaultCountForContentPage
                    isLastPageForComment = commentList.count < Constant.defaultCountForCommentPage
                    
                    nickname = userProfile.user.nickname
                    
                    item = ProfileViewItem(
                        currentSegment: segment,
                        profileInfo: userProfile,
                        contentList: contentList,
                        commentList: commentList
                    )
                }
            } catch {
                await handleError(error: error)
            }
            
            await MainActor.run { isLoading = false }
        }
    }
    
    func fetchMoreContentList(userID: Int, lastContentID: Int) {
        if isLastPageForContent || isLoadingMore { return }
        
        loadingMoreTask?.cancel()
        isLoadingMore = true
        loadingMoreTask = Task {
            do {
                let contentListForNextPage = try await contentRepository.fetchUserContentList(
                    memberID: userID,
                    cursor: lastContentID
                )
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    isLastPageForContent = contentListForNextPage.count < Constant.defaultCountForContentPage
                    item.contentList.append(contentsOf: contentListForNextPage)
                }
            } catch {
                guard !Task.isCancelled else { return }
                await handleError(error: error)
            }
            
            await MainActor.run { isLoadingMore = false }
        }
    }
    
    func fetchMoreCommentList(userID: Int, lastCommentID: Int) {
        if isLastPageForComment || isLoadingMore { return }
        
        loadingMoreTask?.cancel()
        isLoadingMore = true
        loadingMoreTask = Task {
            do {
                let commentListForNextPage = try await commentRepository.fetchUserCommentList(
                    memberID: userID,
                    cursor: lastCommentID
                )
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    isLastPageForComment = commentListForNextPage.count < Constant.defaultCountForCommentPage
                    item.commentList.append(contentsOf: commentListForNextPage)
                }
            } catch {
                guard !Task.isCancelled else { return }
                await handleError(error: error)
            }
            
            await MainActor.run { isLoadingMore = false }
        }
    }
    
    @MainActor
    func handleError(error: Error) {
        errorMessage = error.localizedDescription
    }
    
    enum Constant {
        static let initialCursor = -1
        static let defaultCountForContentPage = 15
        static let defaultCountForCommentPage = 10
    }
}
