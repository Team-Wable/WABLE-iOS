//
//  NewsHeaderView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit

import SnapKit
import Then

final class NewsHeaderView: UICollectionReusableView {
    
    // MARK: - UIComponent
    
    private let bannerImageView: UIImageView = .init(image: .imgNewsbanner).then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
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
}

// MARK: - Setup Method

private extension NewsHeaderView {
    func setupView() {
        backgroundColor = .wableWhite
        
        addSubviews(bannerImageView)
    }
    
    func setupConstraint() {
        bannerImageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(bannerImageView.snp.width).multipliedBy(64.0/344.0)
        }
    }
}
