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
    
    // MARK: - Setup

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
                let condition = sessionInfo.isNewUser && sessionInfo.user.nickname != "" && sessionInfo.user.profileURL != nil
                
                WableLogger.log("새로운 유저인가요? : \(sessionInfo.isNewUser && sessionInfo.user.nickname != "")", for: .debug)
                
                condition ? owner.navigateToOnboarding() : owner.navigateToHome()
            }
            .store(in: cancelBag)
    }
    
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
    
    private func navigateToHome() {
        let tabBarController = TabBarController()
        
        present(tabBarController, animated: true)
    }
}
