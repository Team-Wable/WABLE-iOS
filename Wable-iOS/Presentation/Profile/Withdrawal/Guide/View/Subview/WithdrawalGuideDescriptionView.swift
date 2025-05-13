//
//  WithdrawalGuideDescriptionView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then

final class WithdrawalGuideDescriptionView: UIView {
    private let imageView = UIImageView(image: .icDot)
    
    private let descriptionLabel = UILabel().then {
        $0.attributedText = "설명".pretendardString(with: .body2)
        $0.textColor = .gray800
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(description: String) {
        descriptionLabel.text = description
    }
    
    private func setupView() {
        addSubviews(imageView, descriptionLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing)
        }
    }
}
