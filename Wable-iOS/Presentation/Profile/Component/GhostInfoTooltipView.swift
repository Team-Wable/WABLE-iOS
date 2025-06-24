//
//  GhostInfoTooltipView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 6/24/25.
//

import UIKit

import SnapKit

final class GhostInfoTooltipView: UIView {
    private let tooltipImageView = UIImageView(image: .imgGhostTooltip).then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let label = UILabel().then {
        $0.textColor = .wableWhite
        $0.attributedText = StringLiterals.Ghost.tooltip
            .pretendardString(with: .caption3)
            .highlight(textColor: .sky50, to: "투명도란?")
        $0.numberOfLines = 0
    }
    
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

private extension GhostInfoTooltipView {
    func setupView() {
        addSubviews(tooltipImageView, label)
    }
    
    func setupConstraint() {
        tooltipImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}

