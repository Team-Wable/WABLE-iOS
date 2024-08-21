//
//  InfoTabView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit
import Lottie

final class InfoTabView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    private lazy var infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Icon.icInfoPurple
        return imageView
    }()
    
    private lazy var infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.TabBar.info
        label.font = .head1
        label.textColor = .wableBlack
        return label
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

extension InfoTabView {
    private func setHierarchy() {
        self.addSubviews(infoImageView,
                         infoTitleLabel,
                         tabLottieAnimationView)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(58.adjusted)
        }
        
        infoImageView.snp.makeConstraints {
            $0.height.width.equalTo(32.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.top.equalToSuperview().inset(12.adjusted)
            
        }
        
        infoTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(infoImageView.snp.trailing).offset(6.adjusted)
            $0.centerY.equalTo(infoImageView)
        }
        
        tabLottieAnimationView.snp.makeConstraints {
            $0.height.equalTo(2)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
