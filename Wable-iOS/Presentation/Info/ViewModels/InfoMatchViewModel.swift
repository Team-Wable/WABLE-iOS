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
        let matchInfoSubject = CurrentValueSubject<[TodayMatchesDTO], Never>([])
        
        input.viewWillAppear
            .sink { _ in
                InfoAPI.shared.getMatchInfo { [weak self] result in
                    guard let result = self?.validateResult(result) as? [TodayMatchesDTO] else { return }
                    let formattedResult = self?.processGameSchedules(result)
                    matchInfoSubject.send(formattedResult ?? [])
                }
            }
            .store(in: cancelBag)
        
        return Output(matchInfo: matchInfoSubject.eraseToAnyPublisher())
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

// MARK: - Private Method

private extension InfoMatchViewModel {
    func validateResult(_ result: NetworkResult<Any>) -> Any?{
        switch result{
        case .success(let data):
            return data
        case .requestErr(let message):
            print(message)
        case .pathErr:
            print("path 혹은 method 오류입니다.🤯")
        case .serverErr:
            print("서버 내 오류입니다.🎯")
        case .networkFail:
            print("네트워크가 불안정합니다.💡")
        case .decodedErr:
            print("디코딩 오류가 발생했습니다.🕹️")
        case .authorizationFail(_):
            print("인증 오류가 발생했습니다. 다시 로그인해주세요🔐")
        }
        return nil
    }
    
    func processGameSchedules(_ schedules: [TodayMatchesDTO]) -> [TodayMatchesDTO] {
        var formattedSchedules = schedules
        for i in 0..<formattedSchedules.count {
            formattedSchedules[i].formatDate()
        }
        
        return formattedSchedules
    }
}
