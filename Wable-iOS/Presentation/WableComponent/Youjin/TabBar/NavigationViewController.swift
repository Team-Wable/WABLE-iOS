//
//  NavigationViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import UIKit

class NavigationViewController: UIViewController {
    
    // MARK: - UIComponent
    
    let navigationView: NavigationView = NavigationView(type: .flow)

    // MARK: - LifeCycle
    
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
        navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        navigationView.dismissButton.addTarget(self, action: #selector(dismissButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - @objc Method
    
    @objc func backButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissButtonDidTap() {
        self.dismiss(animated: true)
    }
}
