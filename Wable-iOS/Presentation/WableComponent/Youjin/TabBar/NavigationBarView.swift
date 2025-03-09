//
//  NavigationView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

import Lottie

enum NavigationType {
    case home(hasNewNotification: Bool)
    case flow
    case page(type: PageType, text: String)
    case hub(isBeta: Bool)
}

enum PageType {
    case plain
    case detail
    case profile
}

final class NavigationView: UIView {
    
    // MARK: Property
    
    private let type: NavigationType
    private let hasNewNotification: Bool
    
    private let logoImageView: UIImageView = UIImageView().then {
        $0.image = .logoType
        $0.contentMode = .scaleAspectFit
    }
    
    private let underLineView: LottieAnimationView = LottieAnimationView(name: LottieType.tab.rawValue).then {
        $0.contentMode = .scaleToFill
        $0.loopMode = .loop
        $0.play()
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
    
    private lazy var notificationButton: UIButton = UIButton().then {
        $0.setImage(.icNotiDefault, for: .normal)
        $0.setImage(.icNotiBadge, for: .highlighted)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var backButton: UIButton = UIButton().then {
        $0.setImage(.icBack, for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var dismissButton: UIButton = UIButton().then {
        $0.setImage(.icX, for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var menuButton: UIButton = UIButton().then {
        $0.setImage(.btnHamberger, for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - LifeCycle
    
    init(type: NavigationType, hasNewNotification: Bool) {
        self.type = type
        self.hasNewNotification = hasNewNotification
        
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
            underLineView,
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
        
        notificationButton.isHighlighted = hasNewNotification
    }
    
    private func setupConstraint() {
        logoImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        underLineView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.heightEqualTo(2)
        }
        
        hubImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        hubTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(hubImageView.snp.trailing)
        }
        
        betaImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(hubTitleLabel.snp.trailing).offset(2)
        }
        
        pageTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
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

private extension NavigationView {
    func configureVisibleView() {
        var visibleViewList: [UIView] = []
        
        switch type {
        case .home:
            visibleViewList = [
                logoImageView,
                underLineView,
                notificationButton
            ]
        case .flow:
            visibleViewList = [
                backButton,
                dismissButton
            ]
        case .page(type: let type, text: let text):
            switch type {
            case .plain:
                visibleViewList = [pageTitleLabel]
            case .detail:
                visibleViewList = [
                    pageTitleLabel,
                    backButton
                ]
            case .profile:
                visibleViewList = [
                    pageTitleLabel,
                    menuButton
                ]
            }
        case .hub(isBeta: let isBeta):
            visibleViewList = [
                hubImageView,
                hubTitleLabel,
                betaImageView,
                underLineView
            ]
            
            backgroundColor = .wableBlack
        }
        
        visibleViewList.forEach { $0.isHidden = false }
    }
}
