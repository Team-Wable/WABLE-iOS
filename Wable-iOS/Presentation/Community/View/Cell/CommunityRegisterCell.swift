//
//  CommunityRegisterCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class CommunityRegisterCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    private let baseView = CommunityCellBaseView()
    
    // MARK: - Property
    
    var registerClosure: (() -> Void)?
    
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
        
        communityImageView.image = nil
        registerButton.isHidden = false
        
        registerClosure = nil
    }
    
    func configure(imageURL: URL?, title: String, isRegistered: Bool = false) {
        communityImageView.kf.setImage(with: imageURL)
        titleLabel.text = title
        
        registerButton.isHidden = isRegistered
    }
}

// MARK: - Setup Method

private extension CommunityRegisterCell {
    func setupView() {
        contentView.addSubview(baseView)
    }
    
    func setupConstraint() {
        baseView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    func setupAction() {
        registerButton.addTarget(self, action: #selector(registerButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension CommunityRegisterCell {
    @objc func registerButtonDidTap() {
        registerClosure?()
    }
}

// MARK: - Computed Property

private extension CommunityRegisterCell {
    var communityImageView: UIImageView { baseView.communityImageView }
    var titleLabel: UILabel { baseView.titleLabel }
    var registerButton: UIButton { baseView.primaryButton }
}

// MARK: - Constant

private extension CommunityRegisterCell {
    enum Constant {
        static let defaultButtonTitle = "사전 신청하기"
    }
}
