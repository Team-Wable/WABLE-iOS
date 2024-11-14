//
//  InfoMatchViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/28/24.
//

import Foundation
import Combine

final class InfoMatchViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let matchInfo: AnyPublisher<[TodayMatchesDTO], Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let matchInfo = input.viewWillAppear
            .flatMap { _ -> AnyPublisher<[TodayMatchesDTO], Never> in
                return InfoAPI.shared.getMatchInfo()
                    .compactMap { $0 }
                    .mapWableNetworkError()
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        return Output(matchInfo: matchInfo)
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
