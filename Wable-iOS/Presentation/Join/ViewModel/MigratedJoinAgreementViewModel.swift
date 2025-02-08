//
//  MigratedJoinAgreementViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/8/25.
//

import Combine
import Foundation
import UIKit

final class MigratedJoinAgreementViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let service: JoinAPI
    private let userInfo: UserInfoBuilder

    @Published private var isAllChecked = false
    @Published private var isFirstChecked = false
    @Published private var isSecondChecked = false
    @Published private var isThirdChecked = false
    @Published private var isFourthChecked = false
    
    init(
        service: JoinAPI = JoinAPI.shared,
        userInfo: UserInfoBuilder
    ) {
        self.service = service
        self.userInfo = userInfo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Input {
        let allCheckButtonTapped: AnyPublisher<Void, Never>
        let firstCheckButtonTapped: AnyPublisher<Void, Never>
        let secondCheckButtonTapped: AnyPublisher<Void, Never>
        let thirdCheckButtonTapped: AnyPublisher<Void, Never>
        let fourthCheckButtonTapped: AnyPublisher<Void, Never>
        let nextButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let nextButtonDidTapped: AnyPublisher<Void, Never>
        let isAllChecked: AnyPublisher<Bool, Never>
        let isNextButtonEnabled: AnyPublisher<Bool, Never>
        let individualButtonStates: AnyPublisher<[Bool], Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.firstCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isFirstChecked.toggle()
            }
            .store(in: cancelBag)
        
        input.secondCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isSecondChecked.toggle()
            }
            .store(in: cancelBag)
        
        input.thirdCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isThirdChecked.toggle()
            }
            .store(in: cancelBag)
        
        input.fourthCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isFourthChecked.toggle()
                owner.userInfo.setIsAlarmAllowed(owner.isFourthChecked)
            }
            .store(in: cancelBag)
        
        input.allCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                let newState = !(owner.isFirstChecked && owner.isSecondChecked && owner.isThirdChecked && owner.isFourthChecked)
                owner.isFirstChecked = newState
                owner.isSecondChecked = newState
                owner.isThirdChecked = newState
                owner.isFourthChecked = newState
            }
            .store(in: cancelBag)
        
        let individualButtonStates = Publishers.CombineLatest4($isFirstChecked, $isSecondChecked, $isThirdChecked, $isFourthChecked)
            .map { [$0, $1, $2, $3] }
            .eraseToAnyPublisher()
        
        let isAllChecked = individualButtonStates
            .map { $0.allSatisfy { $0 } }
            .eraseToAnyPublisher()
        
        let isNextButtonEnabled = Publishers.CombineLatest3($isFirstChecked, $isSecondChecked, $isThirdChecked)
            .map { $0 && $1 && $2 }
            .eraseToAnyPublisher()
        
        let nextButtonDidTapped = input.nextButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Void, Never> in
                owner.userInfo
                    .setFcmToken(loadUserData()?.fcmToken)
                    .setIsPushAlarmAllowed(loadUserData()?.isPushAlarmAllowed)
                    .setMemberIntro("")
                
                return owner.service.patchUserProfile(requestBody: owner.userInfo.build())
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .map { _ in }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
            
        
        return Output(
            nextButtonDidTapped: nextButtonDidTapped,
            isAllChecked: isAllChecked,
            isNextButtonEnabled: isNextButtonEnabled,
            individualButtonStates: individualButtonStates
        )
    }
}
