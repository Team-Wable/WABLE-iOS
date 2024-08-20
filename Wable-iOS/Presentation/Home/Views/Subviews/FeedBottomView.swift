//
//  FeedBottomView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

import SnapKit

final class FeedBottomView: UIView {
    
    // MARK: - Properties
    
    var commentButtonTapped: (() -> Void)?
    var heartButtonTapped: (() -> Void)?
    var ghostButtonTapped: (() -> Void)?
    var isLiked: Bool = false {
        didSet {
            if isLiked {
                heartButton.setImage(ImageLiterals.Icon.icHeartPress, for: .normal)
            } else {
                heartButton.setImage(ImageLiterals.Icon.icHeartDefault, for: .normal)
            }
        }
    }
    
    // MARK: - UI Components
    
    var ghostButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnGhostDefaultLarge, for: .normal)
        button.setImage(ImageLiterals.Button.btnGhostDisabledLarge, for: .disabled)
        return button
    }()
    
    var heartButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(ImageLiterals.Icon.icHeartDefault, for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(ImageLiterals.Icon.icRipple, for: .normal)
        button.contentHorizontalAlignment = .center
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

extension FeedBottomView {
    private func setHierarchy() {
        self.addSubviews(ghostButton,
                         heartButton,
                         commentButton)
    }
    
    private func setLayout() {
        ghostButton.snp.makeConstraints {
            $0.height.equalTo(31.adjusted)
            $0.width.equalTo(71.adjusted)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        commentButton.snp.makeConstraints {
            $0.height.equalTo(24.adjusted)
            $0.width.equalTo(45.adjusted)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(ghostButton)
        }
        
        heartButton.snp.makeConstraints {
            $0.height.equalTo(24.adjusted)
            $0.width.equalTo(45.adjusted)
            $0.trailing.equalTo(commentButton.snp.leading).offset(-16.adjusted)
            $0.centerY.equalTo(ghostButton)
        }
    }
    
    private func setAddTarget() {
        ghostButton.addTarget(self, action: #selector(ghostButtonDidTapped), for: .touchUpInside)
        heartButton.addTarget(self, action: #selector(heartButtonDidTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonDidTapped), for: .touchUpInside)
    }
    
    @objc
    private func ghostButtonDidTapped() {
        ghostButtonTapped?()
    }
    
    @objc
    private func heartButtonDidTapped() {
        heartButtonTapped?()
    }
    
    @objc
    private func commentButtonDidTapped() {
        commentButtonTapped?()
    }
    
    func bind(heart: Int, comment: Int) {
        heartButton.setTitleWithConfiguration("\(heart)", font: .caption1, textColor: .wableBlack)
        commentButton.setTitleWithConfiguration("\(comment)", font: .caption1, textColor: .wableBlack)
    }
}
