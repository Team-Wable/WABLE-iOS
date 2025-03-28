//
//  NotificationCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/26/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class NotificationCell: UICollectionViewCell {
    
    // MARK: - UIComponent

    private let profileImageView = UIImageView().then {
        $0.image = .imgProfileSmall
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    private let labelStackView = UIStackView(axis: .vertical).then {
        $0.spacing = 4
    }
    
    private let contentLabel = UILabel().then {
        $0.attributedText = "내용".pretendardString(with: .body4)
        $0.numberOfLines = 3
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let timeLabel = UILabel().then {
        $0.attributedText = "1분전".pretendardString(with: .caption2)
        $0.textColor = .gray600
    }
    
    // MARK: - Property

    var profileImageViewDidTapAction: (() -> Void)? {
        didSet {
            profileImageView.isUserInteractionEnabled = profileImageViewDidTapAction != nil
        }
    }
    
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
        
        profileImageView.kf.cancelDownloadTask()
        profileImageView.image = .imgProfileSmall
        contentLabel.text = nil
        timeLabel.text = nil
        profileImageViewDidTapAction = nil
    }
    
    func configure(
        imageURL: URL?,
        content: String,
        time: String
    ) {
        profileImageView.kf.setImage(with: imageURL, placeholder: UIImage(resource: .imgProfileSmall))
        contentLabel.text = content
        timeLabel.text = time
    }
}

// MARK: - Setup Method

private extension NotificationCell {
    func setupView() {
        labelStackView.addArrangedSubviews(
            contentLabel,
            timeLabel
        )
        
        contentView.addSubviews(
            profileImageView,
            labelStackView
        )
    }
    
    func setupConstraint() {
        profileImageView.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.adjustedWidthEqualTo(36)
            make.adjustedHeightEqualTo(36)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
        }
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageViewDidTap() {
        profileImageViewDidTapAction?()
    }
}
