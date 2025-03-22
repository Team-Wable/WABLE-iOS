//
//  GameScheduleEmptyView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit

import SnapKit
import Then

final class GameScheduleEmptyView: UIView {
    
    // MARK: - UIComponent

    private let imageView: UIImageView = .init(image: .imgNotiEmpty)
    
    private let titleLabel: UILabel = .init().then {
        $0.attributedText = "아직 진행 예정인 경기가 없어요.".pretendardString(with: .body2)
        $0.textColor = .gray500
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Method

private extension GameScheduleEmptyView {
    func setupView() {
        addSubviews(
            imageView,
            titleLabel
        )
    }
    
    func setupConstraint() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(28)
            make.height.equalTo(imageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
    }
}

