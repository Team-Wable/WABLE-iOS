//
//  CommunityViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Combine
import Foundation

final class CommunityViewModel {
    private let useCase: CommunityUseCase
    
    init(useCase: CommunityUseCase) {
        self.useCase = useCase
    }
}

extension CommunityViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
        let viewDidRefresh: Driver<Void>
        let register: Driver<Int>
    }
    
    struct Output {
        let communityItems: Driver<[CommunityItem]>
        let isLoading: Driver<Bool>
        let completeRegistration: Driver<LCKTeam?>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let registrationRelay = CurrentValueRelay<CommunityRegistration>(.initialState())
        let communityListRelay = CurrentValueRelay<[Community]>([])
        let isLoadingRelay = CurrentValueRelay<Bool>(false)
        let completeRegistrationRelay = CurrentValueRelay<LCKTeam?>(nil)
        
        useCase.isUserRegistered()
            .catch { error -> AnyPublisher<CommunityRegistration, Never> in
                WableLogger.log("\(error.localizedDescription)", for: .error)
                return .just(.initialState())
            }
            .sink { status in
                registrationRelay.send(status)
            }
            .store(in: cancelBag)
        
        input.viewDidLoad
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Community], Never> in
                owner.useCase.fetchCommunityList()
                    .catch { error -> AnyPublisher<[Community], Never> in
                        WableLogger.log("\(error.localizedDescription)", for: .error)
                        return .just([])
                    }
                    .eraseToAnyPublisher()
            }
            .filter { !$0.isEmpty }
            .sink { communityListRelay.send($0) }
            .store(in: cancelBag)
        
        let viewDidRefresh = input.viewDidRefresh
            .handleEvents(receiveOutput: { _ in
                isLoadingRelay.send(true)
            })
        
        Publishers.Merge(input.viewDidLoad, viewDidRefresh)
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Community], Never> in
                owner.useCase.fetchCommunityList()
                    .catch { error -> AnyPublisher<[Community], Never> in
                        WableLogger.log("\(error.localizedDescription)", for: .error)
                        return .just([])
                    }
                    .eraseToAnyPublisher()
            }
            .filter { !$0.isEmpty }
            .sink { communityListRelay.send($0) }
            .store(in: cancelBag)
        
        input.register
            .compactMap { communityListRelay.value[$0].team }
            .handleEvents(receiveOutput: { team in
                registrationRelay.send(.init(team: team, hasRegisteredTeam: true))
            })
            .withUnretained(self)
            .flatMap { owner, team -> AnyPublisher<Double, Never> in
                return owner.useCase.register(for: team)
                    .map { value -> Double? in
                        return value
                    }
                    .catch { error -> AnyPublisher<Double?, Never> in
                        WableLogger.log("\(error.localizedDescription)", for: .error)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .handleEvents(receiveOutput: { _ in
                        completeRegistrationRelay.send(team)
                    })
                    .eraseToAnyPublisher()
            }
            .sink { updatedRate in
                guard let team = registrationRelay.value.team else { return }
                
                var community = communityListRelay.value.first { $0.team == team }
                community?.registrationRate = updatedRate
            }
            .store(in: cancelBag)
        
        let communityItems = Publishers.CombineLatest(communityListRelay, registrationRelay)
            .map { communityList, registration in
                return communityList.map {
                    let isRegistered = registration.hasRegisteredTeam
                    ? $0.team == registration.team
                    : false
                    
                    return CommunityItem(
                        community: $0,
                        isRegistered: isRegistered,
                        hasRegisteredCommunity: registration.hasRegisteredTeam
                    )
                }
                .sorted { $0.isRegistered && !$1.isRegistered }
            }
            .handleEvents(receiveOutput: { _ in
                isLoadingRelay.send(false)
            })
            .asDriver()
        
        return Output(
            communityItems: communityItems,
            isLoading: isLoadingRelay.asDriver(),
            completeRegistration: completeRegistrationRelay.asDriver()
        )
    }
}
