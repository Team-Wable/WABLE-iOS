//
//  GameScheduleHeaderView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import UIKit

import SnapKit
import Then

final class GameScheduleHeaderView: UICollectionReusableView {
    
    // MARK: - UIComponent

    private let labelStackView = UIStackView(axis: .horizontal).then {
        $0.spacing = 8
    }
    
    private let todayDescriptionLabel = UILabel().then {
        $0.attributedText = "TODAY".pretendardString(with: .head2)
        $0.textColor = .info
        $0.isHidden = true
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray900
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        todayDescriptionLabel.isHidden = true
    }
}

// MARK: - Public Method

extension GameScheduleHeaderView {
    func configure(isToday: Bool, date: String) {
        todayDescriptionLabel.isHidden = !isToday
        dateLabel.attributedText = date.pretendardString(with: .body3)
    }
}

// MARK: - Setup Method

private extension GameScheduleHeaderView {
    func setupView() {
        labelStackView.addArrangedSubviews(
            todayDescriptionLabel,
            dateLabel
        )
        
        addSubview(labelStackView)
    }
    
    func setupConstraint() {
        labelStackView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
        }
    }
}
