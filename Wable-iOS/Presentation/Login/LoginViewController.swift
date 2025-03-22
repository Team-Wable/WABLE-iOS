//
//  LoginViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import AuthenticationServices
import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: Property

    private let userSessionRepository: UserSessionRepository = UserSessionRepositoryImpl(
        userDefaults: UserDefaultsStorage(
            userDefaults: UserDefaults.standard,
            jsonEncoder: JSONEncoder(),
            jsonDecoder: JSONDecoder()
        )
    )
    
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
    
    private lazy var kakaoButton: UIButton = UIButton(configuration: UIButton.Configuration.plain()).then {
        $0.configuration?.image = .btnKakao
        $0.backgroundColor = UIColor("FEE500")
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private lazy var appleButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton(
        type: .continue,
        style: .black
    )
    
    // TODO: - 자동 로그인 구현 이후 삭제 필요
    
    private lazy var tempButton: UIButton = UIButton(configuration: .filled()).then {
        $0.configuration?.attributedTitle = "하하 우리 인생 화이팅".pretendardString(with: .body3)
        $0.configuration?.baseBackgroundColor = .sky50
        $0.configuration?.baseForegroundColor = .wableWhite
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
}

// MARK: - Private Extension

private extension LoginViewController {
    
    // MARK: - Setup

    func setupView() {
        view.addSubviews(backgroundImageView, logoImageView, loginImageView, titleLabel, kakaoButton, appleButton, tempButton)
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
        kakaoButton.addTarget(self, action: #selector(kakaoButtonDidTap), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleButtonDidTap), for: .touchUpInside)
        tempButton.addAction(
            .init(
                handler: { _ in
                    let tabBarController = TabBarController().then {
                        $0.modalPresentationStyle = .fullScreen
                    }
                    
                    self.present(tabBarController, animated: true)
                }),
            for: .touchUpInside
        )
    }
    
    // MARK: - @objc Method
    
    @objc func kakaoButtonDidTap() {
        // TODO: 카카오 로그인 기능 구현 필요
    }
    
    @objc func appleButtonDidTap() {
        // TODO: 애플 로그인 기능 구현 필요
        
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
        
        self.present(noticeViewController, animated: true)
    }
}
