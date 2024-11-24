//
//  NewsCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit

import SnapKit

final class NewsCell: UICollectionViewCell {
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.adjusted
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textColor = .wableBlack
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textColor = .gray600
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .caption4
        label.textColor = .gray500
        return label
    }()
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        imageView.isHidden = true
    }
}

// MARK: - Private Method

private extension NewsCell {
    func setupView() {
        [titleLabel, bodyLabel, timeLabel].forEach { labelStackView.addArrangedSubview($0) }
        
        [imageView, labelStackView].forEach { contentStackView.addArrangedSubview($0) }
        
        contentView.addSubviews(contentStackView, bottomBorder)
    }
    
    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.width.equalTo(70.adjusted)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(12)
        }
        
        bottomBorder.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
