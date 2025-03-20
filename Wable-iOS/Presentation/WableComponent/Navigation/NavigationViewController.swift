//
//  NavigationViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import UIKit

class NavigationViewController: UIViewController {
    
    // MARK: - UIComponent
    
    let navigationView: NavigationView

    // MARK: - LifeCycle
    
    init(type: NavigationType) {
        self.navigationView = NavigationView(type: type)
        
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
    }
}

// MARK: - Private Extension

private extension NavigationViewController {
    
    // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubview(navigationView)
    }
    
    func setupConstraint() {
        navigationView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.adjustedHeightEqualTo(60)
        }
    }
    
    func setupAction() {
        navigationView.notificationButton.addTarget(self, action: #selector(notificationButtonDidTap), for: .touchUpInside)
        navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        navigationView.dismissButton.addTarget(self, action: #selector(dismissButtonDidTap), for: .touchUpInside)
        navigationView.menuButton.addTarget(self, action: #selector(menuButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - @objc Method
    
    @objc func notificationButtonDidTap() {
        // TODO: 알림 화면으로 이동하는 로직 구현 필요
    }
    
    @objc func backButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc func menuButtonDidTap() {
        // TODO: 프로필 바텀시트 올라오는 로직 구현 필요
    }
}
