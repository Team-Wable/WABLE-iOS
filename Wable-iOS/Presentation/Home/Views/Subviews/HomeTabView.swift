//
//  HomeTabView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

import SnapKit
import Lottie

final class HomeTabView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Logo.logoType
        return imageView
    }()
    
    private lazy var tabLottieAnimationView: LottieAnimationView = {
        let animation = LottieAnimationView(name: "wable_tab")
        animation.contentMode = .scaleAspectFill
        animation.loopMode = .loop
        animation.play()
        return animation
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension HomeTabView {
    private func setHierarchy() {
        self.addSubviews(logoImageView,
                         tabLottieAnimationView)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(60.adjusted)
        }
        
        logoImageView.snp.makeConstraints {
            $0.height.equalTo(28.adjusted)
            $0.width.equalTo(81.adjusted)
            $0.top.leading.equalToSuperview().inset(16.adjusted)
        }
        
        tabLottieAnimationView.snp.makeConstraints {
            $0.height.equalTo(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
