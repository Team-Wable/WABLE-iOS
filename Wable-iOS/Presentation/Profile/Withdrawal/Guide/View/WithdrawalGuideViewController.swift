//
//  WithdrawalGuideViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

final class WithdrawalGuideViewController: UIViewController {
    
    private let viewModel: WithdrawalGuideViewModel
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
        let output = viewModel.bind(with: cancelBag).share()
        
        output
            .map(\.isNextEnabled)
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
        
        output
            .map(\.isWithdrawSuccess)
            .filter { $0 }
            .sink { [weak self] _ in self?.presentLoginView() }
            .store(in: cancelBag)
    }
    
    // MARK: - Helper

    func presentLoginView() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return WableLogger.log("SceneDelegate 찾을 수 없음.", for: .debug)
        }
        
        // TODO: SceneDelegate의 루트뷰컨 설정
    }
    
    // MARK: - Action

    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func checkboxButtonDidTap() {
        viewModel.input.checkbox.send()
    }
    
    @objc func nextButtonDidTap() {
        let wableSheet = WableSheetViewController(title: "계정을 삭제하시겠어요?")
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let withdrawAction = WableSheetAction(title: "삭제하기", style: .primary) { [weak self] in
            self?.viewModel.input.withdraw.send()
        }
        wableSheet.addActions(cancelAction, withdrawAction)
        present(wableSheet, animated: true)
    }
}
