//
//  InfoMatchViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/28/24.
//

import Foundation
import Combine

final class InfoMatchViewModel {
    private let service: InfoAPI
    private let matchesDateFormatter = TodayMatchesDateFormmatter()
    
    init(service: InfoAPI = .shared) {
        self.service = service
    }
}

extension InfoMatchViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let gameType: AnyPublisher<LCKGameTypeDTO, Never>
        let matchInfo: AnyPublisher<[TodayMatchesDTO], Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let matchInfo = input.viewWillAppear
            .flatMap { [weak self] _ -> AnyPublisher<[TodayMatchesDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return service.getMatchInfo()
                    .mapWableNetworkError()
                    .replaceError(with: [])
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .compactMap { [weak self] in
                self?.matchesDateFormatter.formatting($0)
            }
            .eraseToAnyPublisher()
        
        let gameType = input.viewWillAppear
            .flatMap { [weak self] _ -> AnyPublisher<LCKGameTypeDTO?, Never> in
                guard let self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                return service.getGameType()
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .removeDuplicates(by: { $0.lckGameType == $1.lckGameType })
            .eraseToAnyPublisher()
        
        return Output(
            gameType: gameType,
            matchInfo: matchInfo
        )
    }
}

extension InfoMatchViewModel {
    func isDateToday(dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd (EEE)"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone.current
        return dateString == dateFormatter.string(from: Date())
    }
}
