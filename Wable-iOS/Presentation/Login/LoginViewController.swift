//
//  LoginViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import AuthenticationServices
import Combine
import UIKit

import CombineCocoa

final class LoginViewController: UIViewController {
    
    // MARK: Property
    
    private let viewModel: LoginViewModel
    private let cancelBag = CancelBag()
    
    // MARK: UIComponent
    
    private let backgroundImageView: UIImageView = UIImageView(image: .imgLoginBackground).then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let logoImageView: UIImageView = UIImageView(image: .logoType)
    
    private let loginImageView: UIImageView = UIImageView(image: .imgLogin)
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = "클린 LCK 팬 커뮤니티\n와블에서 함께 해요".pretendardString(with: .head0)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .black
    }
    
    private lazy var kakaoButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.image = .btnKakao
        $0.backgroundColor = UIColor("FEE500")
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private lazy var appleButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.image = .btnApple
        $0.backgroundColor = .wableBlack
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    // TODO: - 자동 로그인 구현 이후 삭제 필요
    
    private lazy var tempButton: UIButton = UIButton(configuration: .filled()).then {
        $0.configuration?.attributedTitle = "하하 우리 인생 화이팅".pretendardString(with: .body3)
        $0.configuration?.baseBackgroundColor = .sky50
        $0.configuration?.baseForegroundColor = .wableWhite
    }
    
    // MARK: - LifeCycle
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the view controller after the view is loaded into memory.
    /// 
    /// This method performs the initial setup for the login interface by:
    /// - Adding UI components to the view hierarchy.
    /// - Establishing layout constraints.
    /// - Assigning actions to the relevant UI elements.
    /// - Setting up reactive bindings using Combine.
    /// 
    /// Overrides the default implementation to execute these custom setup routines.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
        setupBinding()
    }
}

// MARK: - Private Extension

private extension LoginViewController {
    
    /// Adds the required UI components to the view hierarchy.
    /// 
    /// This method adds the background image, logo, login image, title label, Kakao and Apple login buttons, and a temporary button to the main view. Layout constraints are applied separately.

    func setupView() {
        view.addSubviews(
            backgroundImageView,
            logoImageView,
            loginImageView,
            titleLabel,
            kakaoButton,
            appleButton,
            tempButton
        )
    }
    
    /// Configures SnapKit layout constraints for the login view's UI elements.
    /// 
    /// This method sets the following constraints:
    /// - The background image fills the entire view.
    /// - The logo image is centered horizontally near the top of the safe area with fixed dimensions.
    /// - The title label is centered horizontally below the logo.
    /// - The login image spans the full horizontal width below the title label.
    /// - The apple button is anchored to the bottom safe area with horizontal insets.
    /// - The kakao button is positioned directly above the apple button with the same side insets.
    /// - The temporary button is placed above the kakao button.
    func setupConstraint() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(104)
            $0.height.equalTo(34)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(26)
            $0.centerX.equalToSuperview()
        }
        
        loginImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(42)
            $0.horizontalEdges.equalToSuperview()
        }
        
        appleButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(56)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.bottom.equalTo(appleButton.snp.top).offset(-18)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        
        tempButton.snp.makeConstraints {
            $0.bottom.equalTo(kakaoButton.snp.top).offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
    
    /// Configures the temporary button's tap action.
    /// 
    /// When the temporary button is tapped, this method presents the main TabBarController modally with animation.
    func setupAction() {
        tempButton.addAction(
            .init(
                handler: { _ in
                    let tabBarController = TabBarController()
                    
                    self.present(tabBarController, animated: true)
                }),
            for: .touchUpInside
        )
    }
    
    /// Binds the login button tap events to the view model and navigates based on user session status.
    /// 
    /// This method sets up reactive bindings using Combine for both the Kakao and Apple login buttons. It transforms their tap events into publishers that log debug messages and passes them to the view model's transform function. The resulting output is observed on the main thread; if the session indicates a new user, it triggers navigation to the onboarding flow, otherwise to the home screen.
    func setupBinding() {
        let output = viewModel.transform(
            input: .init(
                kakaoLoginTrigger: kakaoButton
                    .tapPublisher
                    .handleEvents(receiveOutput: { _ in
                        WableLogger.log("카카오 로그인 버튼 트리거 발생", for: .debug)
                    })
                    .eraseToAnyPublisher(),
                appleLoginTrigger: appleButton
                    .tapPublisher
                    .handleEvents(receiveOutput: { _ in
                        WableLogger.log("애플 로그인 버튼 트리거 발생", for: .debug)
                    })
                    .eraseToAnyPublisher()
            ),
            cancelBag: cancelBag
        )
        
        output.account
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, sessionInfo in
                WableLogger.log("새로운 유저인가요? : \(sessionInfo.isNewUser)", for: .debug)
                sessionInfo.isNewUser ? owner.navigateToOnboarding() : owner.navigateToHome()
            }
            .store(in: cancelBag)
    }
    
    /// Presents an onboarding notice and navigates to the year selection flow.
    ///
    /// Displays a modal sheet with an informative title and message. When the user taps the "확인" action,
    /// a full-screen `UINavigationController` containing a `LCKYearViewController` (configured for the onboarding flow)
    /// is presented.
    private func navigateToOnboarding() {
        let noticeViewController = WableSheetViewController(
            title: "앗 잠깐!",
            message: "와블은 온화하면서도 유쾌한 LCK 팬들이 모여 함께 즐기는 공간이에요.\n더 건강하고 즐거운 커뮤니티를 만들어 나가는데 함께 노력해주실거죠?"
        )
        
        noticeViewController.addAction(.init(title: "확인", style: .primary, handler: {
            let navigationController = UINavigationController(rootViewController: LCKYearViewController(type: .flow)).then {
                $0.navigationBar.isHidden = true
                $0.modalPresentationStyle = .fullScreen
            }
            
            self.present(navigationController, animated: true)
        }))
        
        present(noticeViewController, animated: true)
    }
    
    /// Navigates to the home screen by presenting the tab bar interface.
    ///
    /// This method creates a new instance of TabBarController and displays it modally with animation.
    private func navigateToHome() {
        let tabBarController = TabBarController()
        
        present(tabBarController, animated: true)
    }
}
