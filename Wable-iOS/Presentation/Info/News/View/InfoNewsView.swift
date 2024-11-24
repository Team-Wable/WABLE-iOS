//
//  InfoNewsView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit

import SnapKit

final class InfoNewsView: UIView {
    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgNewsBanner
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.adjusted
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.refreshControl = UIRefreshControl()
        return collectionView
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Info.noNewsText
        label.textColor = .gray500
        label.font = .body2
        label.textAlignment = .center
        label.isHidden = true
        return label
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

private extension InfoNewsView {
    func setupView() {
        addSubviews(bannerImageView, collectionView, emptyLabel)
    }
    
    func setupConstraints() {
        bannerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(65.adjustedH)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(bannerImageView.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
