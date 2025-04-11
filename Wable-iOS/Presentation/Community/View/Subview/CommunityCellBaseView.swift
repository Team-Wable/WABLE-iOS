//
//  CommunityCellBaseView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit

import SnapKit
import Then

final class CommunityCellBaseView: UIView {
    
    // MARK: - UIComponent
    
    let communityImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    let titleLabel = UILabel().then {
        $0.attributedText = "이름".pretendardString(with: .head2)
    }
    
    let primaryButton = UIButton(configuration: .filled()).then {
        var config = $0.configuration
        config?.attributedTitle = "타이틀".pretendardString(with: .body3)
        config?.baseForegroundColor = .wableWhite
        config?.baseBackgroundColor = .wableBlack
        config?.cornerStyle = .capsule
        $0.configuration = config
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Method

private extension CommunityCellBaseView {
    func setupView() {
        addSubviews(
            communityImageView,
            titleLabel,
            primaryButton
        )
    }
    
    func setupConstraint() {
        communityImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.adjustedWidthEqualTo(64)
            make.height.equalTo(communityImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(communityImageView)
            make.leading.equalTo(communityImageView.snp.trailing).offset(8)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.centerY.equalTo(communityImageView)
            make.trailing.equalToSuperview()
            make.adjustedHeightEqualTo(32)
        }
    }
}
