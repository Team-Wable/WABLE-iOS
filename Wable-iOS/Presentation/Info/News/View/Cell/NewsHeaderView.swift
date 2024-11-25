//
//  NewsHeaderView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/25/24.
//

import UIKit

import SnapKit

final class NewsHeaderView: UICollectionReusableView {
    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgNewsBanner
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.adjusted
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NewsHeaderView {
    func setupView() {
        addSubview(bannerImageView)
    }
    
    func setupConstraints() {
        bannerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(65.adjustedH)
        }
    }
}
