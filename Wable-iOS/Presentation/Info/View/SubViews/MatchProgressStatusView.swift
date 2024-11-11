//
//  MatchProgressStatusView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class MatchProgressStatusView: UIView {
    private let progressTagImageView = UIImageView()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "17:00"
        label.font = .body3
        label.textColor = .gray900
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MatchProgressStatusView {
    func bind(status: String, time: String) {
        if let matchStatus = MatchProgress(from: status) {
            progressTagImageView.image = matchStatus.image
        }
        
        timeLabel.text = time
    }
}

// MARK: - Private Method

private extension MatchProgressStatusView {
    func setupView() {
        addSubviews(progressTagImageView, timeLabel)
    }
    
    func setupConstraints() {
        progressTagImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(progressTagImageView.snp.trailing).offset(8.adjusted)
            $0.centerY.equalTo(progressTagImageView)
        }
    }
}
