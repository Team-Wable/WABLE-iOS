//
//  NoticeCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit

import SnapKit
import Then

final class NoticeCell: UICollectionViewCell {
    
    // MARK: - UIComponent

    private let titleLabel: UILabel = .init().then {
        $0.attributedText = "제목".pretendardString(with: .body1)
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let timeLabel: UILabel = .init().then {
        $0.attributedText = "1분전".pretendardString(with: .caption4)
        $0.textColor = .gray500
        $0.textAlignment = .right
    }
    
    private let bodyLabel: UILabel = .init().then {
        $0.attributedText = "내용".pretendardString(with: .body4)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
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
    
    func configure(
        title: String,
        time: String,
        body: String
    ) {
        titleLabel.text = title
        timeLabel.text = time
        bodyLabel.text = body
    }
}

// MARK: - Setup Method

private extension NoticeCell {
    func setupView() {
        contentView.addSubviews(
            titleLabel,
            timeLabel,
            bodyLabel,
            divisionLine
        )
    }
    
    func setupConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-68)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        divisionLine.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
