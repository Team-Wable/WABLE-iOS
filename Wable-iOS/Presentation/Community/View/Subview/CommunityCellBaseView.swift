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
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    let nameLabel = UILabel().then {
        $0.attributedText = "이름".pretendardString(with: .head2)
    }
    
    let actionButton = UIButton(configuration: .filled()).then {
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
            imageView,
            nameLabel,
            actionButton
        )
    }
    
    func setupConstraint() {
        imageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(16)
            make.leading.equalToSuperview()
            make.adjustedWidthEqualTo(64)
            make.height.equalTo(imageView.snp.width)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(8)
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview()
            make.adjustedWidthEqualTo(104)
            make.adjustedHeightEqualTo(32)
        }
    }
}
