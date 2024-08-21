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
    
    var heartButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(ImageLiterals.Icon.icHeartDefault, for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    var ghostButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnGhostDefaultSmall, for: .normal)
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
                         ghostButton)
    }
    
    private func setLayout() {
        ghostButton.snp.makeConstraints {
            $0.height.width.equalTo(32.adjusted)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        heartButton.snp.makeConstraints {
            $0.height.equalTo(24.adjusted)
            $0.width.equalTo(45.adjusted)
            $0.trailing.equalTo(ghostButton.snp.leading).offset(-16.adjusted)
            $0.centerY.equalTo(ghostButton)
        }
    }
    
    private func setAddTarget() {
        heartButton.addTarget(self, action: #selector(heartButtonDidTapped), for: .touchUpInside)
        ghostButton.addTarget(self, action: #selector(ghostButtonDidTapped), for: .touchUpInside)
    }
    
    @objc
    private func heartButtonDidTapped() {
        heartButtonTapped?()
    }
    
    @objc
    private func ghostButtonDidTapped() {
        ghostButtonTapped?()
    }
    
    func bind(heart: Int) {
        heartButton.setTitleWithConfiguration("\(heart)", font: .caption1, textColor: .wableBlack)
    }
}
