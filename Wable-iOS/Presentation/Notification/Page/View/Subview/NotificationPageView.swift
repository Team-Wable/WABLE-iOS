//
//  NotificationPageView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/26/25.
//

import UIKit

import SnapKit
import Then

final class NotificationPageView: UIView {
    
    // MARK: - UIComponent
    
    let navigationView = NavigationView(type: .page(type: .detail, title: "알림")).then {
        $0.configureView()
    }
    
    let segmentedControl = WableSegmentedControl(items: ["활동", "정보"]).then {
        $0.selectedSegmentIndex = 0
    }
    
    private let segmentDivisionLine = UIView(backgroundColor: .gray200)
    
    let pagingContainerView = UIView()

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Setup Method

private extension NotificationPageView {
    func setupView() {
        backgroundColor = .wableWhite
        
        addSubviews(
            navigationView,
            segmentedControl,
            segmentDivisionLine,
            pagingContainerView
        )
    }
    
    func setupConstraint() {
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.adjustedHeightEqualTo(48)
        }
        
        segmentDivisionLine.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        pagingContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentDivisionLine.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
        }
    }
}
