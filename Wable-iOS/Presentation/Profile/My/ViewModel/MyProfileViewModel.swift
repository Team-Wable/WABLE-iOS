//
//  MyProfileViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

final class MyProfileViewModel {
    var nickname: String? { userInfo?.nickname }
    
    @Published private(set) var item: ProfileViewItem?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let userInfo: UserSession?
    private let userSessionUseCase: FetchUserInformationUseCase
    private let fetchUserProfileUseCase: FetchUserProfileUseCase
    private let fetchUserCommentListUseCase: FetchUserCommentListUseCase
    private let fetchUserContentListUseCase: FetchUserContentListUseCase
    private let removeUserSessionUseCase: RemoveUserSessionUseCase
    
    private let selectedIndexSubject = PassthroughSubject<Int, Never>()
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
        
        self.userInfo = userinformationUseCase.fetchActiveUserInfo()
        
        bind()
    }
    
    func viewDidLoad() {
        fetchViewItems(segment: .content)
    }
    
    func viewDidRefresh() {
        fetchViewItems(segment: item?.currentSegment ?? .content)
    }
    
    func selectedIndexDidChange(_ selectedIndex: Int) {
        selectedIndexSubject.send(selectedIndex)
    }
    
    func logoutDidTap() {
        removeUserSessionUseCase.removeUserSession()
    }
}

private extension MyProfileViewModel {
    func bind() {
        selectedIndexSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { return ProfileSegmentKind(rawValue: $0) }
            .sink { [weak self] segment in
                self?.item?.currentSegment = segment
            }
            .store(in: cancelBag)
    }
    
    func fetchViewItems(segment: ProfileSegmentKind) {
        guard let userID = userInfo?.id else {
            return WableLogger.log("유저 아이디를 알 수 없음.", for: .debug)
        }
        
        isLoading = true
        
        Task {
            async let userProfile: UserProfile = fetchUserProfileUseCase.execute(userID: userID)
            
            async let contentList: [UserContent] = fetchUserContentListUseCase.execute(
                for: userID, last: Constant.initialCursor
            )
            
            async let commentList: [UserComment] = fetchUserCommentListUseCase.execute(
                for: userID, last: Constant.initialCursor
            )
            
            do {
                let (userProfile, contentList, commentList) = try await (userProfile, contentList, commentList)
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
    
    enum Constant {
        static let initialCursor = -1
    }
}
