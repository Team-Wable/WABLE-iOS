//
//  LCKYearViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import UIKit

final class LCKYearViewController: NavigationViewController {
    
    // MARK: - Property
    
    var isPullDownEnabled = false
    
    // MARK: - UIComponent
    
    private let rootView = LCKYearView()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
}

// MARK: - Private Extension

private extension LCKYearViewController {
    
    // MARK: - Setup
    
    func setupView() {
        view.addSubview(rootView)
    }
    
    func setupConstraint() {
        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupAction() {
        rootView.pullDownButton.addTarget(self, action: #selector(pullDownButtonDidTap), for: .touchUpInside)
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
        rootView.yearButtonList.forEach {
            $0.addTarget(self, action: #selector(yearButtonDidTap), for: .touchUpInside)
        }
    }
    
    // MARK: - @objc Method
    
    @objc func pullDownButtonDidTap() {
        guard var configuration = rootView.pullDownButton.configuration else {
            return
        }
        
        configuration.image = isPullDownEnabled ? .btnDropdownDown : .btnDropdownUp
        rootView.scrollView.isHidden = isPullDownEnabled
        rootView.pullDownButton.configuration = configuration
        
        if !isPullDownEnabled {
            self.rootView.scrollView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.rootView.scrollView.isHidden = false
                self.rootView.scrollView.alpha = 1
            })
        }
        
        isPullDownEnabled.toggle()
    }
    
    @objc func yearButtonDidTap(_ sender: UIButton) {
        rootView.yearButtonList.forEach {
            guard var configuration = $0.configuration else { return }
            let condition: Bool = ($0 == sender)
            
            configuration.background.backgroundColor = condition ? .purple10 : .wableWhite
            configuration.attributedTitle = $0.titleLabel?.text?.pretendardString(with: condition ? .body1 : .body2)
            configuration.baseForegroundColor = condition ? .purple50 : .wableBlack
            
            $0.configuration = configuration
        }
        
        rootView.pullDownButton.configuration?.attributedTitle = sender.titleLabel?.text?
            .pretendardString(with: .body1)
    }
    
    @objc func nextButtonDidTap() {
        
    }
}
