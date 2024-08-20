//
//  ViewModelType.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output
}
