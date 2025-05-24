//
//  OtherProfileEmptyCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/20/25.
//

import UIKit

import SnapKit
import Then

final class OtherProfileEmptyCell: UICollectionViewCell {
    private let textLabel = UILabel().then {
        $0.attributedText = Constant.emptyContentString.pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(currentSegment: ProfileSegment, nickname: String?) {
        let emptyString = currentSegment == .content ? Constant.emptyContentString : Constant.emptyCommentString
        textLabel.text = "아직 \(nickname ?? "알 수 없음")님이" + emptyString
    }
}

private extension OtherProfileEmptyCell {
    func setupCell() {
        contentView.addSubview(textLabel)
        
        textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.centerX.equalToSuperview()
        }
    }
    
    enum Constant {
        static let emptyContentString = "\n글을 작성하지 않았어요."
        static let emptyCommentString = "\n댓글을 작성하지 않았어요."
    }
}
