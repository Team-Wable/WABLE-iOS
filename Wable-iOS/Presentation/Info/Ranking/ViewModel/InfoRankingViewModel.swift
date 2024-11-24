//
//  InfoRankingViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/22/24.
//

import Foundation
import Combine

final class InfoRankingViewModel {
    private let infoAPI: InfoAPI
    
    init(infoAPI: InfoAPI = InfoAPI.shared) {
        self.infoAPI = infoAPI
    }
}

extension InfoRankingViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let gameType: AnyPublisher<LCKGameTypeDTO, Never>
        let teamRanks: AnyPublisher<[LCKTeamRankDTO], Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let gameType = input.viewWillAppear
            .flatMap { [weak self] _ -> AnyPublisher<LCKGameTypeDTO?, Never> in
                guard let self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                return infoAPI.getGameType()
                    .compactMap { $0 }
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .removeDuplicates(by: { $0.lckGameType == $1.lckGameType })
            .eraseToAnyPublisher()
        
        let teamRanks = input.viewWillAppear
            .flatMap { [weak self] _ -> AnyPublisher<[LCKTeamRankDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return infoAPI.getTeamRank()
                    .compactMap { $0 }
                    .mapWableNetworkError()
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        
        return Output(
            gameType: gameType,
            teamRanks: teamRanks
        )
    }
}
