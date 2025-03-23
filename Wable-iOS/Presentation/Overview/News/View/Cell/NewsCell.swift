//
//  NewsCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class NewsCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    private let contentStackView: UIStackView = .init(axis: .horizontal).then {
        $0.spacing = 16
    }

    private let imageView: UIImageView = .init().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    private let labelStackView: UIStackView = .init(axis: .vertical).then {
        $0.alignment = .leading
        $0.distribution = .fillProportionally
    }
    
    private let titleLabel: UILabel = .init().then {
        $0.attributedText = "제목".pretendardString(with: .body3)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let bodyLabel: UILabel = .init().then {
        $0.attributedText = "본문".pretendardString(with: .body4)
        $0.textColor = .gray600
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let timeLabel: UILabel = .init().then {
        $0.attributedText = "1분전".pretendardString(with: .caption4)
        $0.textColor = UIColor("AEAEAE")
    }
    
    private let divisionLine: UIView = .init(backgroundColor: .gray200)
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        imageView.isHidden = true
    }
    
    func configure(
        imageURL: URL?,
        title: String,
        body: String,
        time: String
    ) {
        imageView.kf.setImage(with: imageURL)
        titleLabel.text = title
        bodyLabel.text = body
        timeLabel.text = time
    }
}

// MARK: - Setup Method

private extension NewsCell {
    func setupView() {
        labelStackView.addArrangedSubviews(
            titleLabel,
            bodyLabel,
            timeLabel
        )
        
        contentStackView.addArrangedSubviews(
            imageView,
            labelStackView
        )
        
        contentView.addSubview(contentStackView)
    }
    
    func setupConstraint() {
        imageView.snp.makeConstraints { make in
            make.adjustedWidthEqualTo(100)
            make.adjustedHeightEqualTo(70)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.horizontalEdges.equalToSuperview()
        }
        
        divisionLine.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
