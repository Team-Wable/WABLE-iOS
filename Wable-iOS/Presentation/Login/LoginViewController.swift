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
    
    // MARK: - Property
    
    private let viewModel: LoginViewModel
    private let cancelBag = CancelBag()
    
    var navigateToOnboarding: (() -> Void)?
    var navigateToHome: (() -> Void)?
    
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
        $0.numberOfLines = 0
        $0.textColor = .wableBlack
        $0.textAlignment = .center
        $0.attributedText = StringLiterals.Login.title.pretendardString(with: .head0)
    }
    
    private lazy var kakaoButton: UIButton = UIButton().then {
        $0.clipsToBounds = true
        $0.contentVerticalAlignment = .fill
        $0.setImage(.btnKakao, for: .normal)
        $0.contentHorizontalAlignment = .fill
        $0.backgroundColor = UIColor("FEE500")
        $0.layer.cornerRadius = 6.adjustedHeight
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private lazy var appleButton: UIButton = UIButton().then {
        $0.clipsToBounds = true
        $0.backgroundColor = .wableBlack
        $0.contentVerticalAlignment = .fill
        $0.setImage(.btnApple, for: .normal)
        $0.contentHorizontalAlignment = .fill
        $0.layer.cornerRadius = 6.adjustedHeight
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: - Life Cycle
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraint()
        setupBinding()
    }
}

// MARK: - Setup Method

private extension LoginViewController {
    func setupConstraint() {
        view.addSubviews(
            backgroundImageView,
            logoImageView,
            loginImageView,
            titleLabel,
            kakaoButton,
            appleButton
        )
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.adjustedWidthEqualTo(104)
            $0.adjustedHeightEqualTo(34)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(44)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(26)
        }
        
        loginImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(42)
        }
        
        appleButton.snp.makeConstraints {
            $0.adjustedHeightEqualTo(50)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(56)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.adjustedHeightEqualTo(50)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(appleButton.snp.top).offset(-18)
        }
    }
    
    func setupBinding() {
        let output = viewModel.transform(
            input: .init(
                kakaoLoginTrigger: kakaoButton
                    .publisher(for: .touchUpInside)
                    .handleEvents(receiveOutput: { _ in
                        AmplitudeManager.shared.trackEvent(tag: .clickSigninKakao)
                    })
                    .eraseToAnyPublisher(),
                appleLoginTrigger: appleButton
                    .publisher(for: .touchUpInside)
                    .handleEvents(receiveOutput: { _ in
                        AmplitudeManager.shared.trackEvent(tag: .clickSigninApple)
                    })
                    .eraseToAnyPublisher()
            ),
            cancelBag: cancelBag
        )
        
        output.account
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, sessionInfo in
                let condition = sessionInfo.isNewUser || sessionInfo.user.nickname == ""

                if condition { AmplitudeManager.shared.trackEvent(tag: .clickAgreePopupSignup) }
                condition ? owner.navigateToOnboarding?() : owner.navigateToHome?()
            }
            .store(in: cancelBag)
        
        output.error
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, error in
                let toast = WableSheetViewController(
                    title: "로그인 중 오류가 발생했어요",
                    message: "\(error.localizedDescription)\n다시 시도해주세요."
                )
                
                toast.addAction(.init(title: "확인", style: .primary))
                owner.present(toast, animated: true)
            }
            .store(in: cancelBag)
    }
}
