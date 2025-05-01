//
//  CreateViewitViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/1/25.
//

import Combine
import UIKit

final class CreateViewitViewModel {
    private static let urlDetector: NSDataDetector? = {
        do {
            return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        } catch {
            WableLogger.log("NSDataDetector 초기화 오류: \(error.localizedDescription)", for: .error)
            return nil
        }
    }()
}

extension CreateViewitViewModel: ViewModelType {
    struct Input {
        let urlTextFieldDidChange: Driver<String>
    }
    
    struct Output {
        let nextButtonIsEnabled: Driver<Bool>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let nextButtonIsEnabled = input.urlTextFieldDidChange
            .map {
                guard let detector = Self.urlDetector else {
                    return false
                }
                
                let range = NSRange(location: 0, length: $0.utf16.count)
                let matches = detector.matches(in: $0, options: [], range: range)
                
                if let match = matches.first,
                   match.range.length == $0.utf16.count {
                    return true
                }
                
                return false
            }
            .asDriver()
        
        return Output(
            nextButtonIsEnabled: nextButtonIsEnabled
        )
    }
}
