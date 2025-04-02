//
//  WritePostViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/1/25.
//


import Combine
import Foundation
import UIKit

final class WritePostViewModel {
    private let createContentUseCase: CreateContentUseCase
    
    init(createContentUseCase: CreateContentUseCase) {
        self.createContentUseCase = createContentUseCase
    }
}

extension WritePostViewModel: ViewModelType {
    struct Input {
        let postButtonDidTap: AnyPublisher<(title: String, content: String?, image: UIImage?), Never>
    }
    
    struct Output {
        let postSuccess: Driver<Void>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let postSuccessRelay = PassthroughRelay<Void>()
        
        input.postButtonDidTap
            .flatMap { (title, content, image) -> AnyPublisher<Void, WableError> in
                WableLogger.log("postButtonDidTap flatMap", for: .debug)
                return self.createContentUseCase.execute(
                    title: title,
                    text: content ?? "",
                    image: image?.jpegData(compressionQuality: 0.1)
                )
            }
            .sink(
                receiveCompletion: { completion in },
                receiveValue: { value in
                    postSuccessRelay.send(())
                    WableLogger.log("postSuccessRelay 전송 완료", for: .debug)
                }
            )
            .store(in: cancelBag)
        
        return Output(
            postSuccess: postSuccessRelay.asDriver()
        )
    }
}
