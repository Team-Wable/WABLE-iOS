//
//  CommunityViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Combine
import Foundation
import UserNotifications

final class CommunityViewModel {
    @Injected private var repository: CommunityRepository
    
    private var userRegistrationState = CommunityRegistration.initialState()
    
    private let communityListSubject = CurrentValueSubject<[Community], Never>([])
    private let loadingStateSubject = CurrentValueSubject<Bool, Never>(false)
    private let registrationCompletedSubject = CurrentValueSubject<LCKTeam?, Never>(nil)
}

extension CommunityViewModel: ViewModelType {
    struct Input {
        let refresh: Driver<Void>
        let register: Driver<Int>
        let checkNotificationAuthorization: Driver<Void>
    }
    
    struct Output {
        let communityItems: Driver<[CommunityItem]>
        let isLoading: Driver<Bool>
        let registrationCompleted: Driver<LCKTeam?>
        let isNotificationAuthorized: Driver<Bool>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        bindInitialLoad(cancelBag: cancelBag)
        bindRefresh(input: input, cancelBag: cancelBag)
        bindRegister(input: input, cancelBag: cancelBag)
        
        return Output(
            communityItems: createItemsPublisher(),
            isLoading: loadingStateSubject.removeDuplicates().asDriver(),
            registrationCompleted: registrationCompletedSubject.asDriver(),
            isNotificationAuthorized: createIsNotificationAuthorizedPublisher(input: input)
        )
    }
}

private extension CommunityViewModel {
    func bindInitialLoad(cancelBag: CancelBag) {
        repository.checkUserRegistration()
            .catch { error -> AnyPublisher<CommunityRegistration, Never> in
                WableLogger.log("\(error.localizedDescription)", for: .error)
                return .just(.initialState())
            }
            .handleEvents(receiveOutput: { [weak self] in self?.userRegistrationState = $0 })
            .withUnretained(self)
            .flatMap(maxPublishers: .max(1)) { owner, _ -> AnyPublisher<[Community], Never> in
                owner.fetchCommunityList()
            }
            .sink { [weak self] in self?.communityListSubject.send($0) }
            .store(in: cancelBag)
    }
    
    func bindRefresh(input: Input, cancelBag: CancelBag) {
        input.refresh
            .handleEvents(receiveOutput: { [weak self] in self?.loadingStateSubject.send(true) })
            .withUnretained(self)
            .flatMap {  owner, _ -> AnyPublisher<[Community], Never> in
                owner.fetchCommunityList()
            }
            .sink { [weak self] in self?.communityListSubject.send($0) }
            .store(in: cancelBag)
    }
    
    func bindRegister(input: Input, cancelBag: CancelBag) {
        let teamPublisher: AnyPublisher<LCKTeam, Never> = input.register
            .compactMap { [weak self] in self?.communityListSubject.value[$0].team }
            .handleEvents(receiveOutput: { [weak self] team in
                self?.userRegistrationState = CommunityRegistration(team: team, hasRegisteredTeam: true)
            })
            .eraseToAnyPublisher()
       
        teamPublisher
            .withUnretained(self)
            .flatMap { owner, team -> AnyPublisher<(LCKTeam, Double), Never> in
                return owner.repository.updateRegistration(communityName: team.rawValue)
                    .map { Optional.some($0) }
                    .catch { error -> AnyPublisher<Double?, Never> in
                        WableLogger.log("\(error.localizedDescription)", for: .error)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .handleEvents(receiveOutput: { [weak self] _ in self?.registrationCompletedSubject.send(team) })
                    .map { (team, $0) }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] team, updatedRate in
                guard let index = self?.communityListSubject.value.firstIndex(where: { $0.team == team }) else {
                    return WableLogger.log("팀을 찾을 수 없습니다.", for: .debug)
                }
                
                self?.communityListSubject.value[index].registrationRate = updatedRate
            }
            .store(in: cancelBag)
    }
    
    func createItemsPublisher() -> AnyPublisher<[CommunityItem], Never> {
        return communityListSubject
            .map { [weak self] list in
                guard let registration = self?.userRegistrationState else {
                    return []
                }
                
                return list.map {
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
            .handleEvents(receiveOutput: { [weak self] _ in self?.loadingStateSubject.send(false) })
            .removeDuplicates()
            .asDriver()
    }
    
    func createIsNotificationAuthorizedPublisher(input: Input) -> AnyPublisher<Bool, Never> {
        return input.checkNotificationAuthorization
            .flatMap { _ in
                return Future { promise in
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        promise(.success(settings.authorizationStatus == .authorized))
                    }
                }
            }
            .asDriver()
    }
    
    func fetchCommunityList() -> AnyPublisher<[Community], Never> {
        return repository.fetchCommunityList()
            .catch { error -> AnyPublisher<[Community], Never> in
                WableLogger.log("\(error.localizedDescription)", for: .error)
                return .just([])
            }
            .eraseToAnyPublisher()
    }
}
