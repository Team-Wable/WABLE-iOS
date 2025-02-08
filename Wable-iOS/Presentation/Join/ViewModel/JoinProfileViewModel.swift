//
//  JoinProfileViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import Combine
import Foundation

final class JoinProfileViewModel {
    
    private let cancelBag = CancelBag()
    private let service: JoinAPI
    
    init(service: JoinAPI = JoinAPI.shared) {
        self.service = service
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension JoinProfileViewModel: ViewModelType {
    struct Input {
        let duplicationCheckButtonTapped: AnyPublisher<String, Never>
    }
    
    struct Output {
        let isEnable: AnyPublisher<Bool, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        
        let isEnable: AnyPublisher<Bool, Never> = input.duplicationCheckButtonTapped
            .withUnretained(self)
            .flatMap { owner, nickname in
                owner.service.getIsNicknameDuplicated(nickname: nickname)
                    .mapWableNetworkError()
                    .replaceError(with: EmptyDTO())
                    .compactMap {
                        print("\($0)💫💫💫")
                        return $0 != nil ? false : true
                    }
            }
            .eraseToAnyPublisher()
        
        return Output(isEnable: isEnable)
    }
}
