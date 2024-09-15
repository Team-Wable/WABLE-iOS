//
//  FeedContentView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

import SnapKit

final class FeedContentView: UIView {
    
    // MARK: - UI Components
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .wableBlack
        label.font = .head2
        label.numberOfLines = 0
        return label
    }()
    
    var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray800
        label.font = .body4
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension FeedContentView {
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         photoImageView,
                         contentLabel)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        photoImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10.adjusted)
            $0.height.equalTo(192.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(photoImageView.snp.bottom).offset(10.adjusted)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func bind(title: String, content: String, image: String?) {
        titleLabel.text = title
        contentLabel.text = content
        photoImageView.loadContentImage(url: image ?? "")
        if image != "" {
            photoImageView.isHidden = false
            
            photoImageView.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10.adjusted)
                $0.height.equalTo(192.adjusted)
                $0.leading.trailing.equalToSuperview()
            }
            
            contentLabel.snp.remakeConstraints {
                $0.top.equalTo(photoImageView.snp.bottom).offset(10.adjusted)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            photoImageView.isHidden = true
            contentLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(4.adjusted)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
}
