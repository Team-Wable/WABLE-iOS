//
//  CreateViewitViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/1/25.
//

import Combine
import Foundation

final class CreateViewitViewModel {
    private let useCase: CreateViewitUseCase
    
    init(useCase: CreateViewitUseCase) {
        self.useCase = useCase
    }
}

extension CreateViewitViewModel: ViewModelType {
    struct Input {
        let urlStringChanged: Driver<String>
        let descriptionChanged: Driver<String>
        let upload: Driver<Void>
    }
    
    struct Output {
        let enableNext: Driver<Bool>
        let enableUpload: Driver<Bool>
        let successUpload: Driver<Void>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let urlStringRelay = CurrentValueRelay<String>("")
        let descriptionRelay = CurrentValueRelay<String>("")
        let errorMessageRelay = PassthroughRelay<String>()
        
        input.urlStringChanged
            .subscribe(urlStringRelay)
            .store(in: cancelBag)
        
        input.descriptionChanged
            .subscribe(descriptionRelay)
            .store(in: cancelBag)
        
        let nextButtonIsEnabled = urlStringRelay
            .withUnretained(self)
            .map { owner, text -> Bool in
                owner.useCase.validate(text)
            }
            .asDriver()
        
        let writeButtonIsEnabled = descriptionRelay
            .map { !$0.isEmpty }
            .asDriver()
        
        let successUpload = input.upload
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Void, Never> in
                return owner.useCase.execute(urlString: urlStringRelay.value, description: descriptionRelay.value)
                    .map { $0 }
                    .catch { error -> AnyPublisher<Void?, Never> in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .asDriver()
        
        return Output(
            enableNext: nextButtonIsEnabled,
            enableUpload: writeButtonIsEnabled,
            successUpload: successUpload,
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}
