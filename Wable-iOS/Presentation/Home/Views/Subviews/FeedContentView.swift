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
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .wableBlack
        label.font = .head2
        label.numberOfLines = 0
        return label
    }()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray800
        label.font = .body4
        label.numberOfLines = 0
        return label
    }()
    
    private var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
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
                         contentLabel,
                         photoImageView)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4.adjusted)
        }
        
        photoImageView.snp.makeConstraints {
            $0.height.equalTo(192.adjusted)
            $0.width.equalTo(343.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(contentLabel.snp.bottom).offset(12.adjusted)
        }
    }
    
    func bind(title: String, content: String, image: String?) {
        titleLabel.text = title
        contentLabel.text = content
        photoImageView.load(url: image ?? "")
        if image != "" {
            photoImageView.isHidden = false
            photoImageView.snp.remakeConstraints {
                $0.height.equalTo(192.adjusted)
                $0.width.equalTo(343.adjusted)
                $0.leading.trailing.equalToSuperview()
                $0.top.equalTo(contentLabel.snp.bottom).offset(12.adjusted)
                $0.bottom.equalToSuperview()
            }
        } else {
            photoImageView.isHidden = true
            contentLabel.snp.remakeConstraints {
                $0.leading.trailing.equalTo(titleLabel)
                $0.top.equalTo(titleLabel.snp.bottom).offset(4.adjusted)
                $0.bottom.equalToSuperview()
            }
        }
    }
}
