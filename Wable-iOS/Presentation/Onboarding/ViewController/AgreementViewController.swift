//
//  AgreementViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/21/25.
//


import Combine
import SafariServices
import UIKit

final class AgreementViewController: NavigationViewController {

    // MARK: - Property

    var navigateToHome: (() -> Void)?

    private let viewModel: AgreementViewModel
    private let cancelBag = CancelBag()
    private let completeButtonTappedRelay = PassthroughRelay<Bool>()

    // MARK: - UIComponent

    private let rootView = AgreementView()

    // MARK: - Life Cycle

    init(profileInfo: OnboardingProfileInfo) {
        self.viewModel = AgreementViewModel(profileInfo: profileInfo)

        super.init(type: .flow)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        setupAction()
        setupBinding()
    }
}

// MARK: - Setup Method

private extension AgreementViewController {
    func setupConstraints() {
        view.addSubview(rootView)
        
        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupAction() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        [
            rootView.personalInfoAgreementItemView.checkButton,
            rootView.privacyPolicyAgreementItemView.checkButton,
            rootView.ageAgreementItemView.checkButton,
            rootView.marketingAgreementItemView.checkButton
        ].forEach {
            $0.addTarget(self, action: #selector(checkButtonDidTap(_:)), for: .touchUpInside)
        }
        rootView.personalInfoAgreementItemView.infoButton.addTarget(
            self,
            action: #selector(infoButtonDidTap(_:)),
            for: .touchUpInside
        )
        rootView.privacyPolicyAgreementItemView.infoButton.addTarget(
            self,
            action: #selector(infoButtonDidTap(_:)),
            for: .touchUpInside
        )
        rootView.allAgreementItemView.checkButton.addTarget(
            self,
            action: #selector(allCheckButtonDidTap),
            for: .touchUpInside
        )
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }

    func setupBinding() {
        let input = AgreementViewModel.Input(completeButtonTapped: completeButtonTappedRelay.eraseToAnyPublisher())
        let output = viewModel.transform(input: input, cancelBag: cancelBag)

        output.registrationCompleted
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigateToHome?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    owner.presentWelcomeSheet()
                }
            }
            .store(in: cancelBag)
    }
}

// MARK: - @objc Method

private extension AgreementViewController {
    @objc func checkButtonDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected == false {
            rootView.allAgreementItemView.checkButton.isSelected = false
        }
        
        checkAllAgreeCondition()
        configureNextButton()
    }
    
    @objc func infoButtonDidTap(_ sender: UIButton) {
        let condition = sender == rootView.personalInfoAgreementItemView.infoButton
        let urlString = condition ? StringLiterals.URL.terms : StringLiterals.URL.privacyPolicy
        guard let url = URL(string: urlString) else { return }
        
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .formSheet
        
        self.present(viewController, animated: true)
    }
    
    @objc func allCheckButtonDidTap() {
        rootView.allAgreementItemView.checkButton.isSelected.toggle()
        
        [
            rootView.personalInfoAgreementItemView.checkButton,
            rootView.privacyPolicyAgreementItemView.checkButton,
            rootView.ageAgreementItemView.checkButton,
            rootView.marketingAgreementItemView.checkButton
        ].forEach {
            $0.isSelected = rootView.allAgreementItemView.checkButton.isSelected
        }
        
        configureNextButton()
    }
    
    @objc func nextButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickCompleteTncSignup)
        completeButtonTappedRelay.send(rootView.marketingAgreementItemView.checkButton.isSelected)
    }
}

// MARK: - Helper Method

private extension AgreementViewController {
    func configureNextButton() {
        let condition = rootView.personalInfoAgreementItemView.checkButton.isSelected
        && rootView.privacyPolicyAgreementItemView.checkButton.isSelected
        && rootView.ageAgreementItemView.checkButton.isSelected
        
        rootView.nextButton.isUserInteractionEnabled = condition
        rootView.nextButton.updateStyle(condition ? .primary : .gray)
    }
    
    func checkAllAgreeCondition() {
        rootView.allAgreementItemView.checkButton.isSelected =
        rootView.personalInfoAgreementItemView.checkButton.isSelected &&
        rootView.privacyPolicyAgreementItemView.checkButton.isSelected &&
        rootView.ageAgreementItemView.checkButton.isSelected &&
        rootView.marketingAgreementItemView.checkButton.isSelected
    }
    
    func presentWelcomeSheet() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else { return }

        let noticeViewController = WableSheetViewController(
            title: StringLiterals.Onboarding.completeSheetTitle,
            message: self.viewModel.getWelcomeMessage()
        )

        noticeViewController.addAction(.init(
                title: StringLiterals.Onboarding.completeButtonTitle,
                style: .primary,
                handler: { AmplitudeManager.shared.trackEvent(tag: .clickJoinPopupSignup) }
            )
        )

        rootViewController.present(noticeViewController, animated: true)
    }
}
