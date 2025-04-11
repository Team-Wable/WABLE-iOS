//
//  CommunityViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Combine
import Foundation

final class CommunityViewModel {
    private(set) var registration = CommunityRegistration.initialState()
    
    private let useCase: CommunityUseCase
    
    init(useCase: CommunityUseCase) {
        self.useCase = useCase
    }
}

extension CommunityViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
        let register: Driver<Int>
    }
    
    struct Output {
        let communityItems: Driver<[CommunityItem]>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let communityListRelay = CurrentValueRelay<[Community]>([])
        
        _ = useCase.isUserRegistered()
            .catch { error -> AnyPublisher<CommunityRegistration, Never> in
                WableLogger.log("\(error.localizedDescription)", for: .error)
                return .just(.initialState())
            }
            .sink { [weak self] status in
                self?.registration = status
            }
        
        _ = input.viewDidLoad
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
        
         input.register
            .compactMap { communityListRelay.value[$0].team }
            .handleEvents(receiveOutput: { [weak self] team in
                self?.registration = .init(team: team, hasRegisteredTeam: true)
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
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] updatedRate in
                guard let registration = self?.registration,
                      let team = registration.team
                else {
                    return
                }
                
                var community = communityListRelay.value.first { $0.team == team }
                community?.registrationRate = updatedRate
            }
            .store(in: cancelBag)
        
        let communityItems = communityListRelay
            .map { [weak self] communityList in
                let registration = self?.registration ?? .initialState()
                
                return communityList.map {
                    let isRegistered = registration.hasRegisteredTeam
                    ? $0.team == registration.team
                    : false

                    return CommunityItem(community: $0, isRegistered: isRegistered)
                }
                .sorted { $0.isRegistered && !$1.isRegistered }
            }
            .removeDuplicates()
            .asDriver()
        
        
        return Output(
            communityItems: communityItems
        )
    }
}
