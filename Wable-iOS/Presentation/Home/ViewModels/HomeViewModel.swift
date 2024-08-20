//
//  HomeViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import Foundation
import Combine

final class HomeViewModel {
    
    private let cancelBag = CancelBag()
    
    // MARK: - Input
    
    let commentButtonTapped = PassthroughSubject<Int, Never>()
    let writeButtonTapped = PassthroughSubject<Void, Never>()
    
    // MARK: - Output
    
    let pushViewController = PassthroughSubject<Int, Never>()
    let pushToWriteViewControllr = PassthroughSubject<Void, Never>()
        
    // MARK: - init
    
    init() {
        buttonDidTapped()
    }
    
    // MARK: - Functions
    
    func buttonDidTapped() {
        commentButtonTapped
            .sink { [weak self] index in
                self?.pushViewController.send(index)
                print("탭이여~~~")
            }
            .store(in: cancelBag)
        
        writeButtonTapped
            .sink { [weak self] in
                self?.pushToWriteViewControllr.send()
            }
            .store(in: cancelBag)
    }
}
