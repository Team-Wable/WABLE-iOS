//
//  NotificationPageView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/13/25.
//

import UIKit

import SnapKit

final class NotificationPageView: UIView {
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = NotificationSegmentedControl(items: ["활동", "정보"])
        segmentedControl.backgroundColor = .wableWhite
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.gray600,
             .font: UIFont.body2],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.wableBlack,
             .font: UIFont.body1],
            for: .selected
        )
        return segmentedControl
    }()
    
    let segmentDivisionLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    let pageViewContainer = UIView()
    
    let bottomDivisionLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NotificationPageView {
    func setupView() {
        backgroundColor = .wableWhite
        
        addSubviews(
            segmentedControl,
            segmentDivisionLine,
            pageViewContainer,
            bottomDivisionLine
        )
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(safeArea)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(48.adjustedH)
        }
        
        segmentDivisionLine.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        pageViewContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentDivisionLine.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(bottomDivisionLine.snp.top)
        }
        
        bottomDivisionLine.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
        }
    }
}
