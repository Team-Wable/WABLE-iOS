//
//  WithdrawalGuideViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

final class WithdrawalGuideViewController: UIViewController {
    
    private let viewModel: WithdrawalGuideViewModel
    private let checkboxRelay = PassthroughRelay<Void>()
    private let withdrawRelay = PassthroughRelay<Void>()
    private let cancelBag = CancelBag()
    private let rootView = WithdrawalGuideView()
    
    init(viewModel: WithdrawalGuideViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupAction()
        setupBinding()
    }
}

private extension WithdrawalGuideViewController {
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupAction() {
        rootView.navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        rootView.checkboxButton.addTarget(self, action: #selector(checkboxButtonDidTap), for: .touchUpInside)
        
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
    
    func setupBinding() {
        let input = WithdrawalGuideViewModel.Input(
            checkbox: checkboxRelay.eraseToAnyPublisher(),
            withdraw: withdrawRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.isNextEnabled
            .handleEvents(receiveOutput: { [weak self] isEnabled in
                self?.rootView.checkboxButton.setImage(
                    isEnabled ? .btnCheckboxActive : .btnCheckboxDefault,
                    for: .normal
                )
                
                isEnabled
                ? self?.rootView.nextButton.updateStyle(.primary)
                : self?.rootView.nextButton.updateStyle(.gray)
            })
            .assign(to: \.isEnabled, on: rootView.nextButton)
            .store(in: cancelBag)
        
        output.isWithdrawSuccess
            .filter { $0 }
            .sink { [weak self] _ in self?.presentLoginView() }
            .store(in: cancelBag)
        
        output.errorMessage
            .sink { [weak self] message in
                let alert = UIAlertController(title: "에러가 발생했습니다.", message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Helper

    func presentLoginView() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window
        else {
            return WableLogger.log("SceneDelegate 찾을 수 없음.", for: .debug)
        }
        
        let loginViewController = LoginViewController(
            viewModel: .init(
                updateFCMTokenUseCase: UpdateFCMTokenUseCase(
                    repository: ProfileRepositoryImpl()
                ),
                fetchUserAuthUseCase: FetchUserAuthUseCase(
                    loginRepository: LoginRepositoryImpl(),
                    userSessionRepository: UserSessionRepositoryImpl(
                        userDefaults: UserDefaultsStorage(jsonEncoder: .init(), jsonDecoder: .init())
                    )
                ),
                updateUserSessionUseCase: FetchUserInformationUseCase(
                    repository: UserSessionRepositoryImpl(
                        userDefaults: UserDefaultsStorage(jsonEncoder: .init(), jsonDecoder: .init())
                    )
                ),
                userProfileUseCase: UserProfileUseCase(repository: ProfileRepositoryImpl())
            )
        )
        
        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionCrossDissolve],
            animations: { window.rootViewController = loginViewController },
            completion: nil
        )
    }
    
    // MARK: - Action

    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func checkboxButtonDidTap() {
        checkboxRelay.send()
    }
    
    @objc func nextButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickNextDeleteguide)
        
        let wableSheet = WableSheetViewController(title: StringLiterals.ProfileDelete.withdrawalSheetTitle)
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let withdrawAction = WableSheetAction(title: "삭제하기", style: .primary) { [weak self] in
            AmplitudeManager.shared.trackEvent(tag: .clickDoneDeleteaccount)
            
            self?.withdrawRelay.send()
        }
        wableSheet.addActions(cancelAction, withdrawAction)
        present(wableSheet, animated: true)
    }
}
