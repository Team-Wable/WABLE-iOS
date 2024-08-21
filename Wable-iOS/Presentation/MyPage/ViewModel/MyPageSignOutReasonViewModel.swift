//
//  MyPageSignOutReasonViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import Combine
import Foundation

final class MyPageSignOutReasonViewModel: ViewModelType {
    private let cancelBag = CancelBag()
//    private let networkProvider: NetworkServiceType
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    private let clickedButtonState = PassthroughSubject<(Int, Bool), Never>()
    private let isEnabled = PassthroughSubject<Bool, Never>()
    
    private var isFirstReasonChecked = false
    private var isSecondReasonChecked = false
    private var isThirdReasonChecked = false
    private var isFourthReasonChecked = false
    private var isFifthReasonChecked = false
    private var isSixthReasonChecked = false
    private var isSeventhReasonChecked = false
    
    struct Input {
        let backButtonTapped: AnyPublisher<Void, Never>
        let firstReasonButtonTapped: AnyPublisher<Void, Never>?
        let secondReasonButtonTapped: AnyPublisher<Void, Never>?
        let thirdReasonButtonTapped: AnyPublisher<Void, Never>?
        let fourthReasonButtonTapped: AnyPublisher<Void, Never>?
        let fifthReasonButtonTapped: AnyPublisher<Void, Never>?
        let sixthReasonButtonTapped: AnyPublisher<Void, Never>?
        let seventhReasonButtonTapped: AnyPublisher<Void, Never>?
        let continueButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
        let clickedButtonState: PassthroughSubject<(Int, Bool), Never>
        let isEnable: PassthroughSubject<Bool, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.backButtonTapped
            .sink { _ in
                self.pushOrPopViewController.send(0)
            }
            .store(in: cancelBag)
        
        input.continueButtonTapped
            .sink { _ in
                self.pushOrPopViewController.send(1)
            }
            .store(in: cancelBag)
        
        input.firstReasonButtonTapped?
            .sink { [weak self] _ in
                self?.isFirstReasonChecked.toggle()
                self?.clickedButtonState.send((1, self?.isFirstReasonChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? false)
            }
            .store(in: cancelBag)
        
        input.secondReasonButtonTapped?
            .sink { [weak self] _ in
                self?.isSecondReasonChecked.toggle()
                self?.clickedButtonState.send((2, self?.isSecondReasonChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? false)
            }
            .store(in: cancelBag)
        
        input.thirdReasonButtonTapped?
            .sink { [weak self] _ in
                self?.isThirdReasonChecked.toggle()
                self?.clickedButtonState.send((3, self?.isThirdReasonChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? false)
            }
            .store(in: cancelBag)
        
        input.fourthReasonButtonTapped?
            .sink { [weak self] _ in
                self?.isFourthReasonChecked.toggle()
                self?.clickedButtonState.send((4, self?.isFourthReasonChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? false)
            }
            .store(in: cancelBag)
        
        input.fifthReasonButtonTapped?
            .sink { [weak self] _ in
                self?.isFifthReasonChecked.toggle()
                self?.clickedButtonState.send((5, self?.isFifthReasonChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? false)
            }
            .store(in: cancelBag)
        
        input.sixthReasonButtonTapped?
            .sink { [weak self] _ in
                self?.isSixthReasonChecked.toggle()
                self?.clickedButtonState.send((6, self?.isSixthReasonChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? false)
            }
            .store(in: cancelBag)
        
        input.seventhReasonButtonTapped?
            .sink { [weak self] _ in
                self?.isSeventhReasonChecked.toggle()
                self?.clickedButtonState.send((7, self?.isSeventhReasonChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? false)
            }
            .store(in: cancelBag)
        
        return Output(pushOrPopViewController: pushOrPopViewController,
                      clickedButtonState: clickedButtonState,
                      isEnable: isEnabled)
    }
    
    private func isNextButtonEnabled() -> Bool {
        let checkedCount = [isFirstReasonChecked, isSecondReasonChecked, isThirdReasonChecked, isFourthReasonChecked, isFifthReasonChecked, isSixthReasonChecked, isSeventhReasonChecked].filter { $0 }.count
        
        if checkedCount > 0 {
            return true
        } else {
            return false
        }
    }
    
//    init(networkProvider: NetworkServiceType) {
//        self.networkProvider = networkProvider
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
