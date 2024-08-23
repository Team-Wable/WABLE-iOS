//
//  MyPageSignOutConfirmViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import Combine
import Foundation

final class MyPageSignOutConfirmViewModel: ViewModelType {
    private let cancelBag = CancelBag()
//    private let networkProvider: NetworkServiceType
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    private let isEnabled = PassthroughSubject<Bool, Never>()
    private let isSignOutResult = PassthroughSubject<Int, Never>()
    
    private var checkBoxChecked = false
    
    struct Input {
        let checkButtonTapped: AnyPublisher<Void, Never>
        let signOutButtonTapped: AnyPublisher<String, Never>?
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
        let isEnable: PassthroughSubject<Bool, Never>
        let isSignOutResult: PassthroughSubject<Int, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.checkButtonTapped
            .sink { [weak self] _ in
                self?.checkBoxChecked.toggle()
                self?.isEnabled.send(self?.checkBoxChecked ?? false)
            }
            .store(in: cancelBag)
        
        input.signOutButtonTapped?
            .sink { deletedReason in
                self.isSignOutResult.send(200)
//                Task {
//                    do {
//                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
//                            if let result = try await self.deleteMemberAPI(accessToken: accessToken, deletedReason: deletedReason) {
//                                self.isSignOutResult.send(result.status)
//                                
//                                Amplitude.instance().logEvent("click_account_delete_done")
//                            }
//                        }
//                    } catch {
//                        print(error)
//                    }
//                }
            }
            .store(in: cancelBag)
        return Output(pushOrPopViewController: pushOrPopViewController,
                      isEnable: isEnabled,
                      isSignOutResult: isSignOutResult)
    }
    
//    init(networkProvider: NetworkServiceType) {
//        self.networkProvider = networkProvider
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
