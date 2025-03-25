//
//  RankViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Combine
import Foundation

final class RankViewModel {
    private let overviewRepository: InformationRepository
    
    init(overviewRepository: InformationRepository) {
        self.overviewRepository = overviewRepository
    }
}

extension RankViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidRefresh: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let item: AnyPublisher<RankViewItem, Never>
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
        
        let fetchRanks = overviewRepository.fetchTeamRanks()
            .replaceError(with: [])
            .removeDuplicates()
        
        let item = loadTrigger
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
            })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<RankViewItem, Never> in
                
                return Publishers.CombineLatest(
                    fetchGameType,
                    fetchRanks
                )
                .map { RankViewItem(gameType: $0, ranks: $1) }
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
