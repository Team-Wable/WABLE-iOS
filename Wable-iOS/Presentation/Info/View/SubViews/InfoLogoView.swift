//
//  InfoLogoView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class InfoLogoView: UIView {
    private let infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Icon.icInfoPurple
        return imageView
    }()
    
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.TabBar.info
        label.font = .head2
        label.textColor = .wableWhite
        return label
    }()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Method

private extension InfoLogoView {
    func setupView() {
        backgroundColor = .wableBlack
        
        addSubviews(infoImageView, infoTitleLabel)
    }
    
    func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.equalTo(100.adjusted)
            make.height.equalTo(44.adjustedH)
        }
        
        infoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(32.adjusted)
        }
        
        infoTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoImageView.snp.trailing).offset(6)
            make.centerY.equalTo(infoImageView)
        }
    }
}
