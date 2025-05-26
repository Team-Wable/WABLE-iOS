//
//  LoginViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import AuthenticationServices
import Combine
import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: Property
    
    private let viewModel: LoginViewModel
    private let cancelBag = CancelBag()
    
    // MARK: UIComponent
    
    private let backgroundImageView: UIImageView = UIImageView(image: .imgLoginBackground).then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let logoImageView: UIImageView = UIImageView(image: .logoType).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let loginImageView: UIImageView = UIImageView(image: .imgLogin).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Login.title.pretendardString(with: .head0)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .black
    }
    
    private lazy var kakaoButton: UIButton = UIButton().then {
        $0.setImage(.btnKakao, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.backgroundColor = UIColor("FEE500")
        $0.layer.cornerRadius = 6.adjustedHeight
        $0.clipsToBounds = true
    }
    
    private lazy var appleButton: UIButton = UIButton().then {
        $0.setImage(.btnApple, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.backgroundColor = .wableBlack
        $0.layer.cornerRadius = 6.adjustedHeight
        $0.clipsToBounds = true
    }
    
    // MARK: - LifeCycle
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupBinding()
    }
}

// MARK: - Private Extension

private extension LoginViewController {
    
    // MARK: - Setup

    func setupView() {
        view.addSubviews(
            backgroundImageView,
            logoImageView,
            loginImageView,
            titleLabel,
            kakaoButton,
            appleButton
        )
    }
    
    func setupConstraint() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            $0.centerX.equalToSuperview()
            $0.adjustedWidthEqualTo(104)
            $0.adjustedHeightEqualTo(34)
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
            $0.adjustedHeightEqualTo(50)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.bottom.equalTo(appleButton.snp.top).offset(-18)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(50)
        }
    }
    
    func setupBinding() {
        let output = viewModel.transform(
            input: .init(
                kakaoLoginTrigger: kakaoButton
                    .publisher(for: .touchUpInside)
                    .handleEvents(receiveOutput: { _ in
                        WableLogger.log("카카오 로그인 버튼 트리거 발생", for: .debug)
                    })
                    .eraseToAnyPublisher(),
                appleLoginTrigger: appleButton
                    .publisher(for: .touchUpInside)
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
                let condition = sessionInfo.isNewUser || sessionInfo.user.nickname.isEmpty
                
                WableLogger.log("새로운 유저인가요? : \(sessionInfo.isNewUser || sessionInfo.user.nickname != "")", for: .debug)
                
                condition ? owner.navigateToOnboarding() : owner.navigateToHome()
            }
            .store(in: cancelBag)
    }
    
    private func navigateToOnboarding() {
        let noticeViewController = WableSheetViewController(
            title: "앗 잠깐!",
            message: StringLiterals.Onboarding.enterSheetTitle
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
    
    private func navigateToHome() {
        let tabBarController = TabBarController()
        
        present(tabBarController, animated: true)
    }
}
