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
    @Published private(set) var userNotFound = false
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isReportCompleted = false
    @Published private(set) var isGhostCompleted = false
    @Published private(set) var errorMessage: String?
    
    private var isLastPageForContent = false
    private var isLastPageForComment = false
    private var loadingMoreTask: Task<Void, Never>?
    
    private let userID: Int
    private let fetchUserProfileUseCase: FetchUserProfileUseCase
    private let checkUserRoleUseCase: CheckUserRoleUseCase
    @Injected private var contentRepository: ContentRepository
    @Injected private var commentRepository: CommentRepository
    @Injected private var contentLikedRepository: ContentLikedRepository
    @Injected private var commentLikedRepository: CommentLikedRepository
    @Injected private var reportRepository: ReportRepository
    @Injected private var ghostRepository: GhostRepository
    
    init(
        userID: Int,
        fetchUserProfileUseCase: FetchUserProfileUseCase,
        checkUserRoleUseCase: CheckUserRoleUseCase
    ) {
        self.userID = userID
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.checkUserRoleUseCase = checkUserRoleUseCase
    }
    
    func viewDidRefresh() {
        fetchViewItems(userID: userID, segment: item.currentSegment)
    }
    
    func selectedIndexDidChange(_ selectedIndex: Int) {
        guard let segment = ProfileSegment(rawValue: selectedIndex) else { return }
        item.currentSegment = segment
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
        switch item.currentSegment {
        case .content:
            guard let lastContentID = item.contentList.last?.id else { return }
            fetchMoreContentList(userID: userID, lastContentID: lastContentID)
        case .comment:
            guard let lastCommentID = item.commentList.last?.id else { return }
            fetchMoreCommentList(userID: userID, lastCommentID: lastCommentID)
        }
    }
    
    func toggleLikeContent(for contentID: Int) {
        guard let index = item.contentList.firstIndex(where: { $0.id == contentID }) else { return }
        let isLiked = item.contentList[index].isLiked
        
        Task {
            do {
                isLiked
                ? try await contentLikedRepository.deleteContentLiked(contentID: contentID)
                : try await contentLikedRepository.createContentLiked(
                    contentID: contentID,
                    triggerType: TriggerType.Like.contentLike.rawValue
                )
                await MainActor.run {
                    var contentInfo = item.contentList[index]
                    isLiked ? contentInfo.unlike() : contentInfo.like()
                    item.contentList[index] = contentInfo
                }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func toggleLikeComment(for commentID: Int) {
        guard let index = item.commentList.firstIndex(where: { $0.id == commentID }) else { return }
        let comment = item.commentList[index]
        let isLiked = item.commentList[index].isLiked
        
        Task {
            do {
                isLiked
                ? try await commentLikedRepository.deleteCommentLiked(commentID: commentID)
                : try await commentLikedRepository.createCommentLiked(
                    commentID: commentID,
                    triggerType: TriggerType.Like.commentLike.rawValue,
                    notificationText: item.commentList[index].text
                )
                
                await MainActor.run {
                    var commentInfo = comment
                    isLiked ? commentInfo.unlike() : commentInfo.like()
                    item.commentList[index] = commentInfo
                }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func checkUserRole() -> UserRole? {
        return checkUserRoleUseCase.execute(userID: userID)
    }
    
    func reportContent(for nickname: String, message: String) {
        Task {
            do {
                try await reportRepository.createReport(nickname: nickname, text: message)
                await MainActor.run { isReportCompleted = true }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func reportComment(for nickname: String, message: String) {
        Task {
            do {
                try await reportRepository.createReport(nickname: nickname, text: message)
                await MainActor.run { isReportCompleted = true }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func banContent(for contentID: Int) {
        Task {
            do {
                try await reportRepository.createBan(
                    memberID: userID,
                    triggerType: .content,
                    triggerID: contentID
                )
                
                fetchViewItems(userID: userID, segment: item.currentSegment)
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func banComment(for commentID: Int) {
        Task {
            do {
                try await reportRepository.createBan(
                    memberID: userID,
                    triggerType: .content,
                    triggerID: commentID
                )
                
                fetchViewItems(userID: userID, segment: item.currentSegment)
                
                await MainActor.run { isGhostCompleted = true }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func ghostContent(for contentID: Int, reason: String) {
        Task {
            do {
                try await ghostRepository.postGhostReduction(
                    alarmTriggerType: TriggerType.Ghost.contentGhost.rawValue,
                    alarmTriggerID: contentID,
                    targetMemberID: userID,
                    reason: reason
                )
                
                fetchViewItems(userID: userID, segment: item.currentSegment)
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func ghostComment(for commentID: Int, reason: String) {
        Task {
            do {
                try await ghostRepository.postGhostReduction(
                    alarmTriggerType: TriggerType.Ghost.commentGhost.rawValue,
                    alarmTriggerID: commentID,
                    targetMemberID: userID,
                    reason: reason
                )
                
                fetchViewItems(userID: userID, segment: item.currentSegment)
            } catch {
                await handleError(error: error)
            }
        }
    }
}

private extension OtherProfileViewModel {
    func fetchViewItems(userID: Int, segment: ProfileSegment) {
        isLoading = true
        
        Task {
            async let userProfile: UserProfile = fetchUserProfileUseCase.execute(userID: userID)
            
            async let contentList: [ContentTemp] = contentRepository.fetchUserContentList(
                memberID: userID,
                cursor: IntegerLiterals.initialCursor
            )
            
            async let commentList: [CommentTemp] = commentRepository.fetchUserCommentList(
                memberID: userID,
                cursor: IntegerLiterals.initialCursor
            )
            
            do {
                let (userProfile, contentList, commentList) = try await (userProfile, contentList, commentList)
                
                await MainActor.run {
                    isLastPageForContent = contentList.count < IntegerLiterals.defaultCountPerPage
                    isLastPageForComment = commentList.count < IntegerLiterals.commentCountPerPage
                    
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
                    isLastPageForContent = contentListForNextPage.count < IntegerLiterals.defaultCountPerPage
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
                    isLastPageForComment = commentListForNextPage.count < IntegerLiterals.commentCountPerPage
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
        if case WableError.notFoundMember = error {
            userNotFound = true
            return
        }
        
        errorMessage = error.localizedDescription
    }
}
