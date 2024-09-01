//
//  HomeViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import Foundation
import Combine

final class HomeViewModel {
    
    private let cancelBag = CancelBag()
    
    var cursor: Int = -1
    
    var feedData: [HomeFeedDTO] = []
    var feedDatas: [HomeFeedDTO] = []
    
    // MARK: - Input
    
    let commentButtonTapped = PassthroughSubject<Int, Never>()
    let writeButtonTapped = PassthroughSubject<Void, Never>()
    let viewWillAppear = PassthroughSubject<Void, Never>()
    
    // MARK: - Output
    
    let pushViewController = PassthroughSubject<Int, Never>()
    let pushToWriteViewControllr = PassthroughSubject<Void, Never>()
    let homeFeedDTO = PassthroughSubject<[HomeFeedDTO], Never>()
    
    // MARK: - init
    
    init() {
        buttonDidTapped()
        transform()
    }
    
    // MARK: - Functions
    
    private func buttonDidTapped() {
        commentButtonTapped
            .sink { [weak self] index in
                self?.pushViewController.send(index)
                print("탭이여~~~")
            }
            .store(in: cancelBag)
        
        writeButtonTapped
            .sink { [weak self] in
                self?.pushToWriteViewControllr.send()
            }
            .store(in: cancelBag)
    }
    
    private func transform() {
        viewWillAppear
            .sink { [weak self] in
                HomeAPI.shared.getHomeContent(cursor: self!.cursor) { result in
                    guard let result = self?.validateResult(result) as? [HomeFeedDTO] else { return }
                    
                    if self!.cursor == -1 {
                        self?.feedDatas = []
                        
                        var tempArray: [HomeFeedDTO] = []
                        
                        for content in result {
                            tempArray.append(content)
                        }
                        self?.feedDatas.append(contentsOf: tempArray)
                        self?.homeFeedDTO.send(tempArray)
                    } else {
                        var tempArray: [HomeFeedDTO] = []
                        
                        for content in result {
                            tempArray.append(content)
                        }
                        self?.feedDatas.append(contentsOf: tempArray)
                        self?.homeFeedDTO.send(tempArray)
                    }
                }
            }
            .store(in: cancelBag)
    }
    
    func validateResult(_ result: NetworkResult<Any>) -> Any?{
        switch result{
        case .success(let data):
//            print("성공했습니다.")
//            print("⭐️⭐️⭐️⭐️⭐️⭐️")
//            print("validateResult :\(data)")
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
}
