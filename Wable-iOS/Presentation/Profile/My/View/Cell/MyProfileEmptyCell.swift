//
//  MyProfileEmptyCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/19/25.
//

import UIKit

import SnapKit
import Then

final class MyProfileEmptyCell: UICollectionViewCell {
    private let contentLabel = UILabel().then {
        $0.attributedText = Constant.content.pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let writeButton = WableButton(style: .primary).then {
        $0.configuration?.attributedTitle = "글 작성하러 가기".pretendardString(with: .body1)
    }
    
    private let commentLabel = UILabel().then {
        $0.attributedText = StringLiterals.Empty.comment.pretendardString(with: .body2)
        $0.textColor = .gray500
    }
    
    var writeButtonDidTapClosure: VoidClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(currentSegment: ProfileSegment, nickname: String?) {
        switch currentSegment {
        case .content:
            contentLabel.isHidden = false
            writeButton.isHidden = false
            commentLabel.isHidden = true
        case .comment:
            contentLabel.isHidden = true
            writeButton.isHidden = true
            commentLabel.isHidden = false
        }
        
        if let nickname {
            contentLabel.text = "\(nickname)님, " + Constant.content
        }
    }
}

private extension MyProfileEmptyCell {
    func setupCell() {
        contentView.addSubviews(contentLabel, writeButton, commentLabel)
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.horizontalEdges.equalToSuperview().inset(32)
            make.bottom.equalTo(writeButton.snp.top).offset(-24)
        }
        
        writeButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40)
            make.adjustedHeightEqualTo(48)
            make.bottom.equalToSuperview().offset(-52)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-138)
        }
    }
    
    func setupAction() {
        writeButton.addTarget(self, action: #selector(writeButtonDidTap), for: .touchUpInside)
    }
    
    @objc func writeButtonDidTap() {
        writeButtonDidTapClosure?()
    }
    
    enum Constant {
        static let content: String = "아직 글을 작성하지 않았네요!\n왠지 텅 빈 게시글이 허전하게 느껴져요."
    }
}
