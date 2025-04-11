//
//  ViewitCardButton.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ViewitCardButton: UIButton {
    
    // MARK: - UIComponent

    private let thumbnailImageView = UIImageView(image: .imgViewitThumnail).then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let videoTitleLabel = UILabel().then {
        $0.attributedText = "영상 제목".pretendardString(with: .body3)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let siteNameLabel = UILabel().then {
        $0.attributedText = "사이트 이름".pretendardString(with: .caption4)
        $0.textColor = .gray600
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButton()
        setupConstraint()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageURL: URL?, videoTitle: String, siteName: String) {
        thumbnailImageView.kf.setImage(with: imageURL, placeholder: UIImage(resource: .imgViewitThumnail))
        videoTitleLabel.text = videoTitle
        siteNameLabel.text = siteName
    }
}

// MARK: - Setup Method

private extension ViewitCardButton {
    func setupButton() {
        backgroundColor = .gray100
        
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray200.cgColor
        
        clipsToBounds = true
        
        addSubviews(
            thumbnailImageView,
            videoTitleLabel,
            siteNameLabel
        )
    }
    
    func setupConstraint() {
        thumbnailImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.adjustedWidthEqualTo(344)
            make.adjustedHeightEqualTo(84)
        }
        
        videoTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(8)
        }
        
        siteNameLabel.snp.makeConstraints { make in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(8)
        }
    }
}
