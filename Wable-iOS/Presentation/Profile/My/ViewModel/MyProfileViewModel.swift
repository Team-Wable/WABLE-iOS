//
//  MyProfileViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

final class MyProfileViewModel {
    private(set) var selectedSegment: ProfileSegmentKind = .content
    
    private let userSessionUseCase: FetchUserInformationUseCase
    private let fetchUserProfileUseCase: FetchUserProfileUseCase
    private let fetchUserCommentListUseCase: FetchUserCommentListUseCase
    private let fetchUserContentListUseCase: FetchUserContentListUseCase
    
    private let userSessionRelay = CurrentValueRelay<UserSession?>(nil)
    private let profileViewItemRelay = CurrentValueRelay<ProfileViewItem>(.init(
        profileInfo: nil, content: [], comment: []
    ))
    private let errorMessageRelay = PassthroughRelay<String>()
    
    init(
        userinformationUseCase: FetchUserInformationUseCase,
        fetchUserProfileUseCase: FetchUserProfileUseCase,
        fetchUserCommentListUseCase: FetchUserCommentListUseCase,
        fetchUserContentListUseCase: FetchUserContentListUseCase
    ) {
        self.userSessionUseCase = userinformationUseCase
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchUserCommentListUseCase = fetchUserCommentListUseCase
        self.fetchUserContentListUseCase = fetchUserContentListUseCase
    }
}

extension MyProfileViewModel: ViewModelType {
    struct Input {
        let load: Driver<Void>
        let selectedIndex: Driver<Int>
    }
    
    struct Output {
        let nickname: Driver<String>
        let item: Driver<ProfileViewItem>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let nickname = userSessionUseCase.fetchActiveUserInfo()
            .handleEvents(receiveOutput: { [weak self] session in
                self?.userSessionRelay.send(session)
            })
            .compactMap(\.?.nickname)
            .asDriver()
        
        input.selectedIndex
            .compactMap { ProfileSegmentKind(rawValue: $0) }
            .sink { [weak self] in self?.selectedSegment = $0 }
            .store(in: cancelBag)

        input.load
            .withUnretained(self)
            .flatMap { owner, _ in
                return owner.fetchUserProfile()
                    .combineLatest(
                        owner.fetchUserContentList(cursor: Constant.initialCursor),
                        owner.fetchUserCommentList(cursor: Constant.initialCursor)
                    )
            }
            .map { ProfileViewItem(profileInfo: $0, content: $1, comment: $2) }
            .sink { [weak self] in self?.profileViewItemRelay.send($0) }
            .store(in: cancelBag)
        
        return Output(
            nickname: nickname,
            item: profileViewItemRelay.asDriver(),
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}

private extension MyProfileViewModel {
    func fetchUserProfile() -> AnyPublisher<UserProfile, Never> {
        return userSessionUseCase.fetchActiveUserID()
            .compactMap { $0 }
            .withUnretained(self)
            .flatMap { owner, userID in
                return owner.fetchUserProfileUseCase.execute(userID: userID)
                    .catch { [weak self] error -> AnyPublisher<UserProfile?, Never> in
                        self?.errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchUserCommentList(cursor: Int) -> AnyPublisher<[UserComment], Never> {
        return userSessionUseCase.fetchActiveUserID()
            .compactMap { $0 }
            .withUnretained(self)
            .flatMap { owner, userID in
                return owner.fetchUserCommentListUseCase.execute(for: userID, last: cursor)
                    .catch { [weak self] error -> AnyPublisher<[UserComment], Never> in
                        self?.errorMessageRelay.send(error.localizedDescription)
                        return .just([])
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchUserContentList(cursor: Int) -> AnyPublisher<[UserContent], Never> {
        return userSessionUseCase.fetchActiveUserID()
            .compactMap { $0 }
            .withUnretained(self)
            .flatMap { owner, userID in
                return owner.fetchUserContentListUseCase.execute(for: userID, last: cursor)
                    .catch { [weak self] error -> AnyPublisher<[UserContent], Never> in
                        self?.errorMessageRelay.send(error.localizedDescription)
                        return .just([])
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    enum Constant {
        static let initialCursor = -1
    }
}
