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
            .map { (title, content, image) -> AnyPublisher<Void, Never> in
                return self.createContentUseCase.execute(
                    title: title,
                    text: content ?? "",
                    image: image?.jpegData(compressionQuality: 0.1)
                )
                .handleEvents(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        WableLogger.log("게시물 생성 중 오류 발생: \(error)", for: .error)
                    }
                })
                .catch { _ -> AnyPublisher<Void, Never> in
                    return Empty<Void, Never>().eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink(
                receiveCompletion: { completion in
                    WableLogger.log("게시물 생성 작업 완료", for: .debug)
                },
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
