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
        let viewDidLoad: Driver<Void>
        let viewDidRefresh: Driver<Void>
    }
    
    struct Output {
        let item: Driver<RankViewItem>
        let isLoading: Driver<Bool>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isLoadingSubject = CurrentValueRelay<Bool>(false)
        
        let loadTrigger = Publishers.Merge(input.viewDidLoad, input.viewDidRefresh)
        
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
                return Publishers.CombineLatest(fetchGameType, fetchRanks)
                .map { RankViewItem(gameType: $0, ranks: $1) }
                .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(false)
            })
            .asDriver()
        
        return Output(
            item: item,
            isLoading: isLoadingSubject.asDriver()
        )
    }
}
