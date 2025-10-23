//
//  OverviewPageView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import UIKit

import SnapKit
import Then

final class OverviewPageView: UIView {
    
    // MARK: - UIComponent

    private let statusBarBackgroundView = UIView(backgroundColor: .wableBlack)
    
    private let navigationView = NavigationView(type: .hub(title: "소식", isBeta: false)).then {
        $0.configureView()
    }
    
    let segmentedControl = WableBadgeSegmentedControl(items: ["경기", "순위", "큐레이션", "공지사항"]).then {
        $0.selectedSegmentIndex = 0
    }
    
    private let segmentDivisionLine = UIView(backgroundColor: .gray200)
    
    let pagingContainerView = UIView()
    
    private let bottomDivisionLine = UIView(backgroundColor: .gray200)
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstriant()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Setup Method

private extension OverviewPageView {
    func setupView() {
        backgroundColor = .wableWhite
        
        addSubviews(
            statusBarBackgroundView,
            navigationView,
            segmentedControl,
            segmentDivisionLine,
            pagingContainerView,
            bottomDivisionLine
        )
    }
    
    func setupConstriant() {
        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(60)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.adjustedHeightEqualTo(44)
        }
        
        segmentDivisionLine.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        pagingContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentDivisionLine.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(bottomDivisionLine.snp.top)
        }
        
        bottomDivisionLine.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeArea)
            make.adjustedHeightEqualTo(1)
        }
    }
}
