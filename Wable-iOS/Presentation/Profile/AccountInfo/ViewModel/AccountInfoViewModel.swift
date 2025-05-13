//
//  AccountInfoViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

final class AccountInfoViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
    }
    
    struct Output: Equatable {
        var items: [AccountInfoCellItem] = []
        var errorMessage: String?
    }
    
    let input = Input()
    
    func bind(with cancelBag: CancelBag) -> AnyPublisher<Output, Never> {
        let outputSubject = CurrentValueSubject<Output, Never>(Output())
        
//        input.load
//            .flatMap { _ in
//
//                // TODO: 유저 정보 조회
//
//            }
//            .sink { }
//            .store(in: cancelBag)
        
        input.load
            .sink { _ in
                outputSubject.value.items = [
                    .init(title: "소셜 로그인", description: "kakao"),
                    .init(title: "버전 정보", description: "ㅏ민얼이ㅏㄴ머"),
                    .init(title: "아이디", description: "adskljfdsalk"),
                    .init(title: "가입일", description: "asdlkdsajlk"),
                    .init(title: "이용약관", description: "자세히 보기", isUserInteractive: true)
                ]
            }
            .store(in: cancelBag)
        
        return outputSubject
            .removeDuplicates()
            .asDriver()
    }
}
