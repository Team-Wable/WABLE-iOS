//
//  NavigationView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

import Lottie

// MARK: - Navigation Types

/// `UIView`의 네비게이션 타입을 정의하는 `NavigationType` 열거형.
///
/// - `home`: 메인 화면에 사용되는 네비게이션 타입
///   - `hasNewNotification`: 새로운 알림 존재 여부, 해당 값에 따라 알림 버튼 이미지 변경
/// - `flow`: 단계별 흐름(온보딩, 프로세스 등)에 사용되는 네비게이션 타입
/// - `page`: 일반적인 페이지 화면에 사용되는 네비게이션 타입
///   - `type`: 페이지의 타입 (plain, detail, profile)
///   - `text`: 네비게이션 바에 표시될 제목
/// - `hub`: 탭 기반 메인 화면에 사용되는 네비게이션 타입
///   - `text`: 네비게이션 바에 표시될 제목 (기본값: "")
///   - `isBeta`: 베타 기능 표시 여부 (기본값: false)
enum NavigationType {
    /// 페이지 타입을 정의하는 `PageType` 열거형.
    ///
    /// - `plain`: 일반 페이지
    /// - `detail`: 상세 페이지 (뒤로가기 버튼 포함)
    /// - `profile`: 프로필 페이지 (메뉴 버튼 포함)
    enum PageType {
        case plain
        case detail
        case profile
    }
    
    case home(hasNewNotification: Bool)
    case flow
    case page(type: PageType, title: String)
    case hub(title: String = "", isBeta: Bool = false)
    
    var isHub: Bool {
        if case .hub = self {
            return true
        } else {
            return false
        }
    }
}

final class NavigationView: UIView {
    
    // MARK: Property
    
    let type: NavigationType
    
    // MARK: - UIComponent
    
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
        $0.textColor = .wableBlack
    }
    
    private let hubTitleLabel: UILabel = UILabel().then {
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
}

// MARK: - Private Extension

private extension NavigationView {
    
    // MARK: - Setup
    
    func setupView() {
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
        
        configureView()
    }
    
    func setupConstraint() {
        logoImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        homeUnderLineView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.adjustedHeightEqualTo(2)
        }
        
        pageUnderLineView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.adjustedHeightEqualTo(1)
        }
        
        hubTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(safeAreaLayoutGuide)
            $0.leading.equalTo(hubImageView.snp.trailing)
        }
        
        hubImageView.snp.makeConstraints {
            $0.centerY.equalTo(hubTitleLabel)
            $0.leading.equalToSuperview().inset(16)
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

// MARK: - Public Extension

extension NavigationView {
    
    // MARK: - Configure Extension
    
    func configureView() {
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
        case .page(type: let type, title: let text):
            pageTitleLabel.attributedText = text.pretendardString(with: .body3)
            
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
        case .hub(title: let text, isBeta: let isBeta):
            backgroundColor = .wableBlack
            hubTitleLabel.attributedText = text.pretendardString(with: .head2)
            
            visibleViewList = [
                hubImageView,
                hubTitleLabel,
                homeUnderLineView
            ]
            
            isBeta ? visibleViewList.append(betaImageView) : nil
        }
        
        visibleViewList.forEach { $0.isHidden = false }
    }
    
    // MARK: - Configure Extension
    
    func setNavigationTitle(text: String) {
        hubTitleLabel.attributedText = text.pretendardString(with: .head2)
    }
}
