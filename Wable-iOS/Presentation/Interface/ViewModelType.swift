//
//  ViewModelType.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input, cancelBag: CancelBag) -> Output
}
