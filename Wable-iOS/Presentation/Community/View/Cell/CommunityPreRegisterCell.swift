//
//  CommunityPreRegisterCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class CommunityPreRegisterCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    private let baseView = CommunityCellBaseView()
    
    // MARK: - Property
    
    var preRegisterClosure: (() -> Void)?
    
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
        preRegisterButton.isHidden = false
        
        preRegisterClosure = nil
    }
    
    func configure(imageURL: URL?, title: String, isPreRegistered: Bool = false) {
        communityImageView.kf.setImage(with: imageURL)
        titleLabel.text = title
        
        preRegisterButton.isHidden = isPreRegistered
    }
}

// MARK: - Setup Method

private extension CommunityPreRegisterCell {
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
        preRegisterButton.addTarget(self, action: #selector(preRegisterButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension CommunityPreRegisterCell {
    @objc func preRegisterButtonDidTap() {
        preRegisterClosure?()
    }
}

// MARK: - Computed Property

private extension CommunityPreRegisterCell {
    var communityImageView: UIImageView { baseView.communityImageView }
    var titleLabel: UILabel { baseView.titleLabel }
    var preRegisterButton: UIButton { baseView.primaryButton }
}

// MARK: - Constant

private extension CommunityPreRegisterCell {
    enum Constant {
        static let defaultButtonTitle = "사전 신청하기"
    }
}
