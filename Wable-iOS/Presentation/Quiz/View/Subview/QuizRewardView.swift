//
//  QuizRewardView.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/22/25.
//


import UIKit

import SnapKit
import Then

public final class QuizRewardView: UIView {
    
    // MARK: - Enum
    
    public enum State {
        case xp
        case top
        case speed
    }
    
    // MARK: Property
    
    private static let maxDisplaySeconds = 99 * 60
    private let state: State
    
    // MARK: - UIComponent
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .body3)
        $0.textAlignment = .center
    }
    
    private let contentLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .head0)
        $0.textAlignment = .center
        $0.textColor = .wableWhite
    }
    
    // MARK: - LifeCycle
    
    init(state: State) {
        self.state = state
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .wableBlack
        layer.cornerRadius = 16.adjustedHeight
        
        addSubviews(titleLabel, contentLabel)
        
        snp.makeConstraints { make in
            make.width.equalTo(97)
            make.height.equalTo(95)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(26)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }
}

// MARK: - Configure Method

public extension QuizRewardView {
    func configureView(isCorrect: Bool? = nil, topPercent: Int? = nil, speed: Int? = nil) {
        switch state {
        case .xp:
            guard let isCorrect = isCorrect else { return }
            let xp = isCorrect ? 8 : 3
            contentLabel.text = "\(xp)"
            titleLabel.text = "획득 XP"
            titleLabel.textColor = .sky50
        case .top:
            guard let topPercent = topPercent else { return }
            contentLabel.text = "\(topPercent)%"
            titleLabel.text = "상위"
            titleLabel.textColor = .blue50
        case .speed:
            guard let speed = speed else { return }
            contentLabel.text = calculateSpeed(speed: speed)
            titleLabel.text = "스피드"
            titleLabel.textColor = .purple50
        }
    }
}

// MARK: - Helper Method

private extension QuizRewardView {
    func calculateSpeed(speed: Int) -> String {
        if speed > QuizRewardView.maxDisplaySeconds { return "99:00" }

        let minute = speed / 60
        let second = speed % 60

        return String(format: "%d:%02d", minute, second)
    }
}
