//
//  JoinProfileViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import Combine
import Foundation

final class JoinProfileViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    private let isNotDuplicated = PassthroughSubject<Bool, Never>()
    
    struct Input {
        let backButtonTapped: AnyPublisher<Void, Never>
        let duplicationCheckButtonTapped: AnyPublisher<String, Never>
        let nextButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
        let isEnable: PassthroughSubject<Bool, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.backButtonTapped
            .sink { _ in
                self.pushOrPopViewController.send(0)
            }
            .store(in: cancelBag)
        
        input.nextButtonTapped
            .sink { _ in
                self.pushOrPopViewController.send(1)
            }
            .store(in: cancelBag)
        
        input.duplicationCheckButtonTapped
            .sink { value in
                self.isNotDuplicated.send(true)
                // 닉네임 중복체크 서버통신
//                Task {
//                    do {
//                        let statusCode = try await self.getNicknameDuplicationAPI(nickname: value)?.status ?? 200
//                        if statusCode == 200 {
//                            self.isNotDuplicated.send(true)
//                        } else {
//                            self.isNotDuplicated.send(false)
//                        }
//                    } catch {
//                        print(error)
//                    }
//                }
            }
            .store(in: self.cancelBag)
        
        return Output(pushOrPopViewController: pushOrPopViewController,
                      isEnable: isNotDuplicated)
    }
}
