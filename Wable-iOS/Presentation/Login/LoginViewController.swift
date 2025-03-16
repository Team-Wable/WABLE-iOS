//
//  LoginViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import AuthenticationServices
import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: UIComponent
    
    private let backgroundImageView: UIImageView = UIImageView(image: .imgLoginBackground)
    
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
        $0.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
    
    private lazy var appleButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton(
        type: .continue,
        style: .black
    )
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    // MARK: - UIActionHandler
    
    private lazy var kakaoButtonHandler: UIActionHandler = { _ in
        // TODO: 카카오 로그인 기능 구현 필요
    }
    
    private lazy var appleButtonHandler: UIActionHandler = { _ in
        // TODO: 애플 로그인 기능 구현 필요
        
        let noticeViewController = WableActionSheetViewController(
            configuraton: .init(
                title: "앗 잠깐!",
                message: "와블은 온화하면서도 유쾌한 LCK 팬들이 모여 함께 즐기는 공간이에요.\n더 건강하고 즐거운 커뮤니티를 만들어 나가는데 함께 노력해주실거죠?",
                confirmButtonTitle: "확인",
                confirmAction: { completion in
                    // TODO: 온보딩 화면으로 전환 필요
                }
            )
        )
        
        self.present(noticeViewController, animated: true)
    }
}

// MARK: - Private Extension

private extension LoginViewController {
    
    // MARK: - Setup

    func setupView() {
        view.backgroundColor = UIColor(patternImage: .imgLoginBackground)
        
        view.addSubviews(logoImageView, loginImageView, titleLabel, kakaoButton, appleButton)
    }
    
    func setupConstraint() {
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
            $0.leading.trailing.equalToSuperview()
        }
        
        kakaoButton.snp.makeConstraints {
            $0.bottom.equalTo(appleButton.snp.top).offset(-18)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        
        appleButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(56)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
    
    func setupAction() {
        kakaoButton.addAction(UIAction(handler: kakaoButtonHandler), for: .touchUpInside)
        appleButton.addAction(UIAction(handler: appleButtonHandler), for: .touchUpInside)
    }
}
