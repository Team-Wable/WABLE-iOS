//
//  InfoMatchViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/28/24.
//

import Foundation
import Combine

final class InfoMatchViewModel {
    
    private let cancelBag = CancelBag()
    
    // MARK: - Input
    
    let viewWillAppear = PassthroughSubject<Void, Never>()
    
    // MARK: - Output
    
    let matchInfoDTO = PassthroughSubject<[TodayMatchesDTO], Never>()
    
    // MARK: - init
    
    init() {
        transform()
    }
    
    private func transform() {
        viewWillAppear
            .sink { [weak self] in
                InfoAPI.shared.getMatchInfo { result in
                    guard let result = self?.validateResult(result) as? [TodayMatchesDTO] else { return }
                    let formatData = self?.processGameSchedules(result)
                    self?.matchInfoDTO.send(formatData ?? [])
                }
            }
            .store(in: cancelBag)
    }
    
    private func validateResult(_ result: NetworkResult<Any>) -> Any?{
        switch result{
        case .success(let data):
//            print("성공했습니다.")
//            print("⭐️⭐️⭐️⭐️⭐️⭐️")
//            print(data)
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
    
    private func processGameSchedules(_ schedules: [TodayMatchesDTO]) -> [TodayMatchesDTO] {
        var formattedSchedules = schedules
        for i in 0..<formattedSchedules.count {
            formattedSchedules[i].formatDate() // date 및 gameDate 변환
        }
        return formattedSchedules
    }
}
