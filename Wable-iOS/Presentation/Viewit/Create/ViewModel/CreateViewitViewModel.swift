//
//  CreateViewitViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/1/25.
//

import Combine
import Foundation

final class CreateViewitViewModel {
    private static let urlDetector: NSDataDetector? = {
        do {
            return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        } catch {
            WableLogger.log("NSDataDetector 초기화 오류: \(error.localizedDescription)", for: .error)
            return nil
        }
    }()
    
    private let useCase: CreateViewitUseCase
    
    init(useCase: CreateViewitUseCase) {
        self.useCase = useCase
    }
}

extension CreateViewitViewModel: ViewModelType {
    struct Input {
        let urlStringChanged: Driver<String>
        let next: Driver<Void>
        let descriptionChanged: Driver<String>
        let upload: Driver<Void>
        let backgroundTap: Driver<Void>
    }
    
    struct Output {
        let enableNext: Driver<Bool>
        let isPossibleToURLUpload: Driver<Bool>
        let enableUpload: Driver<Bool>
        let successUpload: Driver<Bool>
        let showSheetBeforeDismiss: Driver<Bool>
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
                owner.validate(text)
            }
            .asDriver()
        
        let isPossibleToURLUpload = input.next
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Bool, Never> in
                owner.useCase.validate(urlStringRelay.value)
                    .catch { error -> AnyPublisher<Bool, Never> in
                        errorMessageRelay.send("URL을 다시 한번 확인해주세요.")
                        return .just(false)
                    }
                    .filter { $0 }
                    .eraseToAnyPublisher()
            }
            .asDriver()
        
        let writeButtonIsEnabled = descriptionRelay
            .map { !$0.isEmpty }
            .asDriver()
        
        let successUpload = input.upload
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Bool, Never> in
                return owner.useCase.execute(description: descriptionRelay.value)
                    .catch { error -> AnyPublisher<Bool, Never> in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just(false)
                    }
                    .filter { $0 }
                    .eraseToAnyPublisher()
            }
            .asDriver()
        
        let showSheetBeforeDismiss = input.backgroundTap
            .map { _ in !urlStringRelay.value.isEmpty || !descriptionRelay.value.isEmpty }
            .asDriver()
        
        return Output(
            enableNext: nextButtonIsEnabled,
            isPossibleToURLUpload: isPossibleToURLUpload,
            enableUpload: writeButtonIsEnabled,
            successUpload: successUpload,
            showSheetBeforeDismiss: showSheetBeforeDismiss,
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}

private extension CreateViewitViewModel {
    func validate(_ urlString: String) -> Bool {
        guard let detector = Self.urlDetector else {
            return false
        }
        
        if urlString.range(of: "[\\u1100-\\u11FF\\u3130-\\u318F\\uAC00-\\uD7AF]", options: .regularExpression) != nil {
            return false
        }
        
        if urlString.range(of: #"^www\.[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$"#, options: .regularExpression) == nil {
            return false
        }
        
        let range = NSRange(location: 0, length: urlString.utf16.count)
        let matches = detector.matches(in: urlString, options: [], range: range)
        
        if let match = matches.first,
           match.range.length == urlString.utf16.count {
            return true
        }
        
        return false
    }
}
