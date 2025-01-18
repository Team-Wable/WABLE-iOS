//
//  NoticeCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/26/24.
//

import UIKit

import SnapKit

final class NoticeCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body1
        label.textColor = .wableBlack
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .caption4
        label.textColor = .gray500
        label.textAlignment = .right
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textColor = .gray600
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
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
}

// MARK: - Private Method

private extension NoticeCell {
    func setupView() {
        contentView.addSubviews(
            titleLabel,
            timeLabel,
            bodyLabel,
            bottomBorder
        )
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-4)
        }
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(52.adjusted)
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        bottomBorder.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
