//
//  MyPageSignOutConfirmViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import UIKit

class MyPageSignOutConfirmViewController: UIViewController {

    // MARK: - Properties
    
    var signOutReason: [String] = []
    
    private var cancelBag = CancelBag()
    private let viewModel: MyPageSignOutConfirmViewModel
    
    private lazy var checkButtonTapped = self.myView.checkButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var signOutConfirmButtonTapped = self.signOutPopupView.confirmButton.publisher(for: .touchUpInside).map { _ in
        return self.signOutReason
    }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private let myView = MyPageSignOutConfirmView()
    private let topDivisionLine = UIView().makeDivisionLine()
    
    private var signOutPopupView = WablePopupView(popupTitle: StringLiterals.MyPage.myPageSignOutPopupTitleLabel,
                                          popupContent: "",
                                          leftButtonTitle: StringLiterals.MyPage.myPageSignOutPopupLeftButtonTitle,
                                          rightButtonTitle: StringLiterals.MyPage.myPageSignOutPopupRightButtonTitle)
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = myView
    }
    
    init(viewModel: MyPageSignOutConfirmViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("signOutReason: \(signOutReason)")
        setDelegate()
        setAddTarget()
        setNavigationBar()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
    }
}

// MARK: - Extensions

extension MyPageSignOutConfirmViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        self.signOutPopupView.isHidden = true
    }
    
    private func setHierarchy() {
        self.view.addSubviews(topDivisionLine)
        
        if let window = UIApplication.shared.keyWindowInConnectedScenes {
            window.addSubviews(self.signOutPopupView)
        }
    }
    
    private func setLayout() {
        topDivisionLine.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
        }
        
        self.signOutPopupView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setDelegate() {
        self.signOutPopupView.delegate = self
    }
    
    private func setAddTarget() {
        myView.continueButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        self.title = "계정 삭제"
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc
    private func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func bindViewModel() {
        let input = MyPageSignOutConfirmViewModel.Input(checkButtonTapped: checkButtonTapped,
                                                        signOutButtonTapped: signOutConfirmButtonTapped)
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: self.cancelBag)
        
        output.isEnable
            .sink { value in
                if value == true {
                    self.myView.continueButton.isEnabled = true
                    self.myView.checkButton.setImage(ImageLiterals.Button.btnCheckboxActive, for: .normal)
                } else {
                    self.myView.continueButton.isEnabled = false
                    self.myView.checkButton.setImage(ImageLiterals.Button.btnCheckboxDefault, for: .normal)
                }
            }
            .store(in: self.cancelBag)
        
        output.isSignOutResult
            .sink { result in
                if result == 200 {
                    DispatchQueue.main.async {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            DispatchQueue.main.async {
                                let rootViewController = LoginViewController(viewModel: LoginViewModel(networkProvider: NetworkService()))
                                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: rootViewController)
                            }
                        }
                        
                        saveUserData(UserInfo(isSocialLogined: false,
                                              isFirstUser: false,
                                              isJoinedApp: true,
                                              userNickname: "",
                                              memberId: loadUserData()?.memberId ?? 0,
                                              userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                                              fcmToken: loadUserData()?.fcmToken ?? "",
                                              isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
                        
//                        saveUserData(UserInfo(isSocialLogined: false,
//                                              isFirstUser: false,
//                                              isJoinedApp: true,
//                                              userNickname: loadUserData()?.userNickname ?? "",
//                                              memberId: loadUserData()?.memberId ?? 0,
//                                              userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
//                                              fcmToken: loadUserData()?.fcmToken ?? "",
//                                              isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
                    }
                } else if result == 400 {
                    print("존재하지 않는 요청입니다.")
                } else {
                    print("서버 내부에서 오류가 발생했습니다.")
                }
            }
            .store(in: self.cancelBag)
    }
    
    @objc
    private func signOutButtonTapped() {
        showSignOutPopupView()
    }
    
    func showSignOutPopupView() {
        self.signOutPopupView.isHidden = false
    }
}

extension MyPageSignOutConfirmViewController: WablePopupDelegate {
    func cancleButtonTapped() {
        self.signOutPopupView.isHidden = true
    }
    
    func confirmButtonTapped() {
        self.signOutPopupView.isHidden = true
    }
    
    func singleButtonTapped() {
        
    }
}

