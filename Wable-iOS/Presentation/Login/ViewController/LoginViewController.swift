//
//  LoginViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

import SnapKit

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cancelBag = CancelBag()
    private let viewModel: LoginViewModel
    private lazy var kakaoButtonTapped = self.kakaoLoginButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var appleButtonTapped = self.appleLoginButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var newUserSingleButtonTapped = self.newUserPopupView.singleButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private var newUserPopupView = WablePopupView(popupTitle: StringLiterals.Login.loginNewUserPopupTitle,
                                           popupContent: StringLiterals.Login.loginNewUserPopupContent,
                                           singleButtonTitle: StringLiterals.Login.loginNewUserPopupButtonTitle)
    
    private let loginBackgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = ImageLiterals.Image.imgLoginBackground
        return image
    }()
    
    private let loginWableLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = ImageLiterals.Logo.logoType
        return logo
    }()
    
    private let loginTitle: UILabel = {
        let title = UILabel()
        title.text = StringLiterals.Login.loginTitle
        title.textColor = .black
        title.numberOfLines = 2
        title.font = .head0
        title.setTextWithLineHeight(text: title.text, lineHeight: 37.adjusted, alignment: .left)
        title.textAlignment = .center
        return title
    }()
    
    private let loginImage: UIImageView = {
        let image = UIImageView()
        image.image = ImageLiterals.Image.imgLogin
        return image
    }()
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnKakao, for: .normal)
        return button
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnApple, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycles
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setHierarchy()
        setLayout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
    }
}

// MARK: - Extensions

extension LoginViewController {
    private func setUI() {
        view.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.view.addSubviews(loginBackgroundImage,
                              loginWableLogo,
                              loginTitle,
                              loginImage,
                              kakaoLoginButton,
                              appleLoginButton)
    }
    
    private func setLayout() {
        loginBackgroundImage.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(401.adjusted)
        }
        
        loginWableLogo.snp.makeConstraints {
            $0.top.equalToSuperview().inset(statusBarHeight + 44.adjusted)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(104.adjusted)
            $0.height.equalTo(34.adjusted)
        }
        
        loginTitle.snp.makeConstraints {
            $0.top.equalTo(loginWableLogo.snp.bottom).offset(26.adjusted)
            $0.centerX.equalToSuperview()
        }
        
        loginImage.snp.makeConstraints {
            $0.top.equalTo(loginTitle.snp.bottom).offset(42.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-18.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(50.adjusted)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(56.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(50.adjusted)
        }
        
        kakaoLoginButton.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        appleLoginButton.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        let input = LoginViewModel.Input(kakaoButtonTapped: kakaoButtonTapped,
                                         appleButtonTapped: appleButtonTapped,
                                         newUserSingleButtonTapped: newUserSingleButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.userInfoPublisher
            .receive(on: RunLoop.main)
            .sink { value in
                if value {
                    // 신규 유저
                    let viewController = JoinLCKYearViewController(viewModel: JoinLCKYearViewModel())
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    // 기존 유저
                    let viewController = WableTabBarController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .store(in: self.cancelBag)
        
        output.showNewUserPopupView
            .receive(on: RunLoop.main)
            .sink { value in
                if let window = UIApplication.shared.keyWindowInConnectedScenes {
                    window.addSubviews(self.newUserPopupView)
                }
                
                self.newUserPopupView.delegate = self
                
                self.newUserPopupView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            }
            .store(in: self.cancelBag)
    }
}

extension LoginViewController: WablePopupDelegate {
    func cancelButtonTapped() {
        
    }
    
    func confirmButtonTapped() {
        
    }
    
    func singleButtonTapped() {
        self.newUserPopupView.removeFromSuperview()
    }
}
