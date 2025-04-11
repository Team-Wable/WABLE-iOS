//
//  CommunityHeaderView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/11/25.
//

import UIKit

import SnapKit
import Then

final class CommunityHeaderView: UICollectionReusableView {
    
    // MARK: - UIComponent

    private let backgroundView = UIView(backgroundColor: .purple10).then {
        $0.layer.cornerRadius = 8
    }
    
    private let textLabel = UILabel().then {
        $0.attributedText = Constant.text.pretendardString(with: .body4)
        $0.textColor = .purple100
        $0.numberOfLines = 0
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

private extension CommunityHeaderView {
    func setupView() {
        backgroundView.addSubview(textLabel)
        
        addSubview(backgroundView)
    }
    
    func setupConstraint() {
        backgroundView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}

// MARK: - Constant

private extension CommunityHeaderView {
    enum Constant {
        static let text = """
                          팀별 커뮤니티 공간을 준비중이에요. 팀별 일정 이상의
                          팬이 모여야 팀별 공간이 열립니다.
                          *계정 1개당 1개의 팀별 공간에만 참여 가능해요!
                          """
    }
}
