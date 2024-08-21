//
//  MyPageSignOutConfirmViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import UIKit

class MyPageSignOutConfirmViewController: UIViewController {

    // MARK: - Properties
    
    var signOutReason = ""
    
    private var cancelBag = CancelBag()
    private let viewModel: MyPageSignOutConfirmViewModel
    
    private lazy var backButtonTapped = self.navigationBackButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var checkButtonTapped = self.myView.checkButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private let myView = MyPageSignOutConfirmView()
    private var navigationBackButton = BackButton()
    
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
        
        setDelegate()
        setAddTarget()
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
    }
    
    private func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton)
    }
    
    private func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
    }
    
    private func setDelegate() {
        
    }
    
    private func setAddTarget() {
        
    }
    
    private func bindViewModel() {
        let input = MyPageSignOutConfirmViewModel.Input(
            backButtonTapped: backButtonTapped,
            checkButtonTapped: checkButtonTapped)
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else if value == 1 {
                    let vc = MyPageSignOutViewController(viewModel: MyPageSignOutReasonViewModel())
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .store(in: self.cancelBag)
                        
                        saveUserData(UserInfo(isSocialLogined: false,
                                              isFirstUser: false,
                                              isJoinedApp: true,
                                              isOnboardingFinished: true,
                                              userNickname: loadUserData()?.userNickname ?? "",
                                              memberId: loadUserData()?.memberId ?? 0,
                                              userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                                              fcmToken: loadUserData()?.fcmToken ?? "",
                                              isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
        
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
    }
}
