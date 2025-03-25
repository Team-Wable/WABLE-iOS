//
//  GameScheduleViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Combine
import Foundation

final class GameScheduleViewModel {
    private let overviewRepository: InformationRepository
    
    init(overviewRepository: InformationRepository) {
        self.overviewRepository = overviewRepository
    }
}

extension GameScheduleViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let item: AnyPublisher<GameScheduleViewItem, Never>
        let isLoading: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        
        let loadTrigger = Publishers.Merge(
            input.viewDidLoad,
            input.viewDidRefresh
        )
        
        let fetchGameType = overviewRepository.fetchGameCategory()
            .replaceError(with: "")
            .filter { !$0.isEmpty }
            .removeDuplicates()
        
        let fetchGameSchedules = overviewRepository.fetchGameSchedules()
            .map { gameSchedules in
                gameSchedules.filter { !$0.games.isEmpty }
            }
            .replaceError(with: [])
            .removeDuplicates()
        
        let item = loadTrigger
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<GameScheduleViewItem, Never> in
                return Publishers.CombineLatest(
                    fetchGameType,
                    fetchGameSchedules
                )
                .map { GameScheduleViewItem(gameType: $0, gameSchedules: $1) }
                .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(false)
            })
            .eraseToAnyPublisher()
        
        return Output(
            item: item,
            isLoading: isLoadingSubject.eraseToAnyPublisher()
        )
    }
}
