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
    
    private let state: State
    
    // MARK: - UIComponent
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .body3)
    }
    
    private let contentLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .head0)
        $0.textColor = .wableWhite
    }
    
    // MARK: - LifeCycle
    
    init(state: State) {
        self.state = state
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            titleLabel.textColor = .sky50
        case .top:
            guard let topPercent = topPercent else { return }
            contentLabel.text = "\(topPercent)%"
            titleLabel.textColor = .blue50
        case .speed:
            guard let speed = speed else { return }
            contentLabel.text = calculateSpeed(speed: speed)
            titleLabel.textColor = .purple50
        }
    }
}

// MARK: - Helper Method

private extension QuizRewardView {
    func calculateSpeed(speed: Int) -> String {
        if speed > 5940 { return "99:00" }

        let minute = speed / 60
        let second = speed % 60

        return String(format: "%d:%02d", minute, second)
    }
}
