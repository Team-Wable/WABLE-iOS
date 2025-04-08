//
//  CommunityPreRegistrationCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class CommunityPreRegistrationCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let nameLabel = UILabel().then {
        $0.attributedText = "이름".pretendardString(with: .head2)
    }
    
    private let preRegistrationButton = UIButton(configuration: .filled()).then {
        var config = $0.configuration
        config?.attributedTitle = Constant.defaultButtonTitle.pretendardString(with: .body3)
        config?.baseForegroundColor = .wableWhite
        config?.baseBackgroundColor = .wableBlack
        config?.cornerStyle = .capsule
        $0.configuration = config
    }
    
    // MARK: - Property
    
    var preRegistrationClosure: (() -> Void)?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        preRegistrationButton.isHidden = false
        
        preRegistrationClosure = nil
    }
    
    func configure(imageURL: URL?, name: String, isCompleted: Bool = false) {
        imageView.kf.setImage(with: imageURL)
        nameLabel.text = name
        
        preRegistrationButton.isHidden = isCompleted
    }
}

// MARK: - Setup Method

private extension CommunityPreRegistrationCell {
    func setupView() {
        contentView.addSubviews(
            imageView,
            nameLabel,
            preRegistrationButton
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
        
        preRegistrationButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview()
            make.adjustedWidthEqualTo(104)
            make.adjustedHeightEqualTo(32)
        }
    }
    
    func setupAction() {
        preRegistrationButton.addTarget(self, action: #selector(preRegistrationButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension CommunityPreRegistrationCell {
    @objc func preRegistrationButtonDidTap() {
        preRegistrationClosure?()
    }
}

// MARK: - Constant

private extension CommunityPreRegistrationCell {
    enum Constant {
        static let defaultButtonTitle = "사전 신청하기"
    }
}
