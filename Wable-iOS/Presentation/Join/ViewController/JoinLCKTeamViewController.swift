//
//  JoinLCKTeamViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import Combine
import UIKit

import SnapKit

final class JoinLCKTeamViewController: UIViewController {
    
    // MARK: - Properties
    
    private let userInfo: UserInfoBuilder
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private var navigationXButton = XButton()
    private let originView = JoinLCKTeamView()
    
    // MARK: - Life Cycles
    
    init(userInfo: UserInfoBuilder) {
        self.userInfo = userInfo
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = originView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
}

// MARK: - Private Method

private extension JoinLCKTeamViewController {
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
        originView.noLCKTeamButton.addTarget(self, action: #selector(noLCKTeamButtonTapped), for: .touchUpInside)
        originView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func xButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = [LoginViewController(viewModel: MigratedLoginViewModel())]
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func noLCKTeamButtonTapped() {
        userInfo.setMemberFanTeam("LCK")
        print("========= UserInfoBuilder 프로퍼티 값=========")
        print("\(userInfo.nickname)")
        print("\(userInfo.memberLckYears)")
        print("\(userInfo.memberIntro)")
        print("\(userInfo.memberFanTeam)")
        print("\(userInfo.memberDefaultProfileImage)")
        print("\(userInfo.isPushAlarmAllowed)")
        print("\(userInfo.isAlarmAllowed)")
        print("\(userInfo.file)")
        print("\(userInfo.fcmToken)")
        print("===========================================")

        let viewController = JoinProfileViewController(viewModel: JoinProfileViewModel(), userInfo: userInfo)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func nextButtonTapped() {
        userInfo.setMemberFanTeam(self.originView.selectedButton?.titleLabel?.text)
        print("========= UserInfoBuilder 프로퍼티 값=========")
        print("\(userInfo.nickname)")
        print("\(userInfo.memberLckYears)")
        print("\(userInfo.memberIntro)")
        print("\(userInfo.memberFanTeam)")
        print("\(userInfo.memberDefaultProfileImage)")
        print("\(userInfo.isPushAlarmAllowed)")
        print("\(userInfo.isAlarmAllowed)")
        print("\(userInfo.file)")
        print("\(userInfo.fcmToken)")
        print("===========================================")

        let viewController = JoinProfileViewController(viewModel: JoinProfileViewModel(), userInfo: userInfo)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
