//
//  FeedDetailBottomView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

import UIKit

import SnapKit

final class FeedDetailBottomView: UIView {
    
    // MARK: - Properties
    
    var ghostButtonTapped: (() -> Void)?
    var heartButtonTapped: (() -> Void)?
    var replyButtonTapped: (() -> Void)?
    var isLiked: Bool = false {
        didSet {
            heartButton.setImage(
                isLiked ? ImageLiterals.Icon.icHeartPressSmall : ImageLiterals.Icon.icHeartGray,
                for: .normal
            )
        }
    }
    
    // MARK: - UI Components
    
    var heartButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(ImageLiterals.Icon.icHeartGray, for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    var ghostButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnGhostDefaultSmall, for: .normal)
        return button
    }()
    
    var replyButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(ImageLiterals.Icon.icRippleRely, for: .normal)
        button.contentHorizontalAlignment = .center
        button.setTitleWithConfiguration("답글쓰기", font: .caption3, textColor: .gray600)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
        setAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension FeedDetailBottomView {
    private func setHierarchy() {
        self.addSubviews(heartButton,
                         replyButton,
                         ghostButton
        )
    }
    
    private func setLayout() {
        heartButton.snp.makeConstraints {
            $0.height.equalTo(21.adjusted)
            $0.width.equalTo(53.adjusted)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        replyButton.snp.makeConstraints {
            $0.height.equalTo(20.adjusted)
            $0.width.equalTo(66.adjusted)
            $0.centerY.equalTo(heartButton)
            $0.leading.equalTo(heartButton.snp.trailing).offset(8.adjusted)
        }
        
        ghostButton.snp.makeConstraints {
            $0.height.width.equalTo(32.adjusted)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setAddTarget() {
        heartButton.addTarget(self, action: #selector(heartButtonDidTapped), for: .touchUpInside)
        ghostButton.addTarget(self, action: #selector(ghostButtonDidTapped), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(replyButtonDidTapped), for: .touchUpInside)
    }
    
    @objc
    private func heartButtonDidTapped() {
        heartButtonTapped?()
    }
    
    @objc
    private func ghostButtonDidTapped() {
        ghostButtonTapped?()
    }
    
    @objc
    private func replyButtonDidTapped() {
        replyButtonTapped?()
    }
    
    func bind(heart: Int) {
        heartButton.setTitleWithConfiguration("\(heart)", font: .caption1, textColor: .gray600)
    }
    
    func setupReplyButtonVisibility(with parentCommnetID: Int) {
        replyButton.isHidden = parentCommnetID != -1
    }
    
    func hideReplyButton() {
        replyButton.isHidden = true
    }
}
