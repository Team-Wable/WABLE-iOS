//
//  MigratedJoinAgreementViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/8/25.
//

import Combine
import SafariServices
import UIKit

import SnapKit

final class MigratedJoinAgreementViewController: UIViewController {
    
    // MARK: - Properties
    
    let useAgreementURL = URL(string: "https://joyous-ghost-8c7.notion.site/c6e26919055a4ff98fd73a8f9b29cb36?pvs=4")
    let privacyURL = URL(string: "https://joyous-ghost-8c7.notion.site/fff08b005ea18052ae0bf9d056c2e830?pvs=4")
    let advertisementURL = URL(string: "https://joyous-ghost-8c7.notion.site/0498674cf44b447da78c54279b5b0e17?pvs=4")
    
    private var cancelBag = CancelBag()
    private let viewModel: MigratedJoinAgreementViewModel
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private var navigationXButton = XButton()
    private let originView = JoinAgreementView()
    private var loadingToastView: UIImageView?
    
    // MARK: - Life Cycles
    
    init(viewModel: MigratedJoinAgreementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = originView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }
}

// MARK: - Extensions

private extension MigratedJoinAgreementViewController {
    func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton, navigationXButton)
    }
    
    func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        
        navigationXButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12.adjusted)
        }
    }
    
    func setAddTarget() {
        navigationXButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        navigationBackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.originView.firstCheckView.moreButton.addTarget(self, action: #selector(firstMoreButtonTapped), for: .touchUpInside)
        self.originView.secondCheckView.moreButton.addTarget(self, action: #selector(secondMoreButtonTapped), for: .touchUpInside)
        self.originView.fourthCheckView.moreButton.addTarget(self, action: #selector(fourthMoreButtonTapped), for: .touchUpInside)
    }
    
    func bindViewModel() {
        let input = MigratedJoinAgreementViewModel.Input(
            allCheckButtonTapped: originView.allCheck.checkButton.tapPublisher.eraseToAnyPublisher(),
            firstCheckButtonTapped: originView.firstCheckView.checkButton.tapPublisher.eraseToAnyPublisher(),
            secondCheckButtonTapped: originView.secondCheckView.checkButton.tapPublisher.eraseToAnyPublisher(),
            thirdCheckButtonTapped: originView.thirdCheckView.checkButton.tapPublisher.eraseToAnyPublisher(),
            fourthCheckButtonTapped: originView.fourthCheckView.checkButton.tapPublisher.eraseToAnyPublisher(),
            nextButtonTapped: originView.JoinCompleteActiveButton.tapPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.isAllChecked
            .receive(on: RunLoop.main)
            .withUnretained(self)
            .sink { owner, isChecked in
                owner.originView.allCheck.checkButton.isSelected = isChecked
            }
            .store(in: cancelBag)
        
        output.isNextButtonEnabled
            .receive(on: RunLoop.main)
            .withUnretained(self)
            .sink { owner, isEnabled in
                owner.originView.JoinCompleteActiveButton.isEnabled = isEnabled
            }
            .store(in: cancelBag)
        
        output.individualButtonStates
            .receive(on: RunLoop.main)
            .withUnretained(self)
            .sink { owner, states in
                owner.originView.firstCheckView.checkButton.isSelected = states[0]
                owner.originView.secondCheckView.checkButton.isSelected = states[1]
                owner.originView.thirdCheckView.checkButton.isSelected = states[2]
                owner.originView.fourthCheckView.checkButton.isSelected = states[3]
            }
            .store(in: cancelBag)
        
        output.nextButtonDidTapped
            .receive(on: RunLoop.main)
            .withUnretained(self)
            .sink { owner, value in
                
                owner.originView.JoinCompleteActiveButton.isEnabled = false
                owner.loadingToastView = UIImageView(image: ImageLiterals.Toast.toastAgreementLoading)
                owner.loadingToastView?.contentMode = .scaleAspectFit
                
                if let loadingToastView = owner.loadingToastView {
                    if let window = UIApplication.shared.keyWindowInConnectedScenes {
                        window.addSubviews(loadingToastView)
                    }
                    
                    loadingToastView.snp.makeConstraints {
                        $0.top.equalToSuperview().inset(32.adjusted)
                        $0.centerX.equalToSuperview()
                        $0.width.equalTo(343.adjusted)
                        $0.height.equalTo(60.adjusted)
                    }
                    
                    UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn) {
                        owner.loadingToastView?.alpha = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        owner.loadingToastView?.removeFromSuperview()
                        let viewController = WableTabBarController()
                        owner.navigationBackButton.removeFromSuperview()
                        owner.originView.JoinCompleteActiveButton.isEnabled = true
                        owner.navigationController?.pushViewController(viewController, animated: true)
                    }
                    
                }
            }
            .store(in: cancelBag)
    }
    
    @objc
    func firstMoreButtonTapped() {
        let useAgreementView: SFSafariViewController
        if let useAgreementURL = self.useAgreementURL {
            useAgreementView = SFSafariViewController(url: useAgreementURL)
            self.present(useAgreementView, animated: true, completion: nil)
        } else {
            print("👻👻👻 유효하지 않은 URL 입니다 👻👻👻")
        }
    }
    
    @objc
    func secondMoreButtonTapped() {
        let useAgreementView: SFSafariViewController
        if let useAgreementURL = self.privacyURL {
            useAgreementView = SFSafariViewController(url: useAgreementURL)
            self.present(useAgreementView, animated: true, completion: nil)
        } else {
            print("👻👻👻 유효하지 않은 URL 입니다 👻👻👻")
        }
    }
    
    @objc
    func fourthMoreButtonTapped() {
        let useAgreementView: SFSafariViewController
        if let useAgreementURL = self.advertisementURL {
            useAgreementView = SFSafariViewController(url: useAgreementURL)
            self.present(useAgreementView, animated: true, completion: nil)
        } else {
            print("👻👻👻 유효하지 않은 URL 입니다 👻👻👻")
        }
    }
    
    @objc
    func xButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = [LoginViewController(viewModel: MigratedLoginViewModel())]
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
    
    @objc
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}
