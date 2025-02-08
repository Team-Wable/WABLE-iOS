//
//  JoinLCKYearViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import SafariServices
import UIKit

import SnapKit

final class JoinLCKYearViewController: UIViewController {
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private var navigationXButton = XButton()
    private let originView = JoinLCKYearView()
    
    // MARK: - Life Cycles
      
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
}

// MARK: - Private Method

extension JoinLCKYearViewController {
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
        originView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func xButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = [LoginViewController(viewModel: MigratedLoginViewModel())]
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
    
    @objc
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func nextButtonTapped() {
        let userInfo = UserInfoBuilder()
            .setMemberLckYears(Int(self.originView.selectedStartYear.text ?? "2024"))
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

        let viewController = JoinLCKTeamViewController(userInfo: userInfo)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
