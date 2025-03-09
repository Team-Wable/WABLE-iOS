//
//  NavigationView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

import Lottie

enum NavigationType: Equatable {
    case home(hasNewNotification: Bool)
    case flow
    case page(type: PageType, text: String)
    case hub(text: String = "", isBeta: Bool = false)
    
    var isHub: Bool {
        if case .hub = self {
            return true
        } else {
            return false
        }
    }
}

enum PageType {
    case plain
    case detail
    case profile
}

final class NavigationView: UIView {
    
    // MARK: Property
    
    let type: NavigationType
    
    private let logoImageView: UIImageView = UIImageView().then {
        $0.image = .logoType
        $0.contentMode = .scaleAspectFit
    }
    
    private let homeUnderLineView: LottieAnimationView = LottieAnimationView(name: LottieType.tab.rawValue).then {
        $0.contentMode = .scaleToFill
        $0.loopMode = .loop
        $0.play()
    }
    
    private let pageUnderLineView: UIView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let hubImageView: UIImageView = UIImageView().then {
        $0.image = .icInfo
        $0.contentMode = .scaleAspectFit
    }
    
    private let betaImageView: UIImageView = UIImageView().then {
        $0.image = .imgBeta
        $0.contentMode = .scaleAspectFit
    }
    
    private let pageTitleLabel: UILabel = UILabel().then {
        $0.font = .pretendard(.body1)
        $0.textColor = .wableBlack
    }
    
    private let hubTitleLabel: UILabel = UILabel().then {
        $0.font = .pretendard(.head2)
        $0.textColor = .wableWhite
    }
    
    lazy var notificationButton: UIButton = UIButton().then {
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var backButton: UIButton = UIButton().then {
        $0.setImage(.icBack, for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var dismissButton: UIButton = UIButton().then {
        $0.setImage(.icX, for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var menuButton: UIButton = UIButton().then {
        $0.setImage(.btnHamberger, for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - LifeCycle
    
    init(type: NavigationType) {
        self.type = type
        
        super.init(frame: .zero)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        [
            logoImageView,
            homeUnderLineView,
            pageUnderLineView,
            hubImageView,
            betaImageView,
            pageTitleLabel,
            hubTitleLabel,
            notificationButton,
            backButton,
            dismissButton,
            menuButton
        ].forEach {
            addSubviews($0)
            $0.isHidden = true
        }
        
        configureVisibleView()
    }
    
    private func setupConstraint() {
        logoImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        homeUnderLineView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.heightEqualTo(2)
        }
        
        pageUnderLineView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.heightEqualTo(1)
        }
        
        hubImageView.snp.makeConstraints {
            $0.centerY.equalTo(safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(16)
        }
        
        hubTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(safeAreaLayoutGuide)
            $0.leading.equalTo(hubImageView.snp.trailing)
        }
        
        betaImageView.snp.makeConstraints {
            $0.centerY.equalTo(safeAreaLayoutGuide)
            $0.leading.equalTo(hubTitleLabel.snp.trailing).offset(2)
        }
        
        pageTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
        }
        
        notificationButton.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview().inset(12)
        }
        
        backButton.snp.makeConstraints {
            $0.verticalEdges.leading.equalToSuperview().inset(12)
        }
        
        dismissButton.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview().inset(12)
        }
        
        menuButton.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview().inset(12)
        }
    }
}

// MARK: - Extension

private extension NavigationView {
    func configureVisibleView() {
        var visibleViewList: [UIView] = []
        
        switch type {
        case .home(hasNewNotification: let hasNewNotification):
            notificationButton.setImage(hasNewNotification ? .icNotiBadge : .icNotiDefault, for: .normal)
            
            visibleViewList = [
                logoImageView,
                homeUnderLineView,
                notificationButton
            ]
        case .flow:
            visibleViewList = [
                backButton,
                dismissButton
            ]
        case .page(type: let type, text: let text):
            pageTitleLabel.text = text
            
            switch type {
            case .plain:
                visibleViewList = [pageTitleLabel]
            case .detail:
                visibleViewList = [
                    pageTitleLabel,
                    backButton,
                    pageUnderLineView
                ]
            case .profile:
                visibleViewList = [
                    pageTitleLabel,
                    menuButton,
                    pageUnderLineView
                ]
            }
        case .hub(text: let text, isBeta: let isBeta):
            backgroundColor = .wableBlack
            isBeta ? visibleViewList.append(betaImageView) : nil
            hubTitleLabel.text = text
            
            visibleViewList = [
                hubImageView,
                hubTitleLabel,
                homeUnderLineView
            ]
        }
        
        visibleViewList.forEach { $0.isHidden = false }
    }
}
