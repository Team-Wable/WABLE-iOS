//
//  MatchProgressStatusView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit
import Lottie

final class MatchProgressStatusView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components

    private var progressTagImageView = UIImageView()
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "17:00"
        label.font = .body3
        label.textColor = .gray900
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

extension MatchProgressStatusView {
    private func setHierarchy() {
        self.addSubviews(progressTagImageView,
                         timeLabel)
    }
    
    private func setLayout() {
        progressTagImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(progressTagImageView.snp.trailing).offset(8.adjusted)
            $0.centerY.equalTo(progressTagImageView)
        }

    }
    
    func bind(status: String, time: String) {
        if let matchStatus = MatchProgress(from: status) {
            progressTagImageView.image = matchStatus.image
        }
        
        timeLabel.text = time
    }
}
