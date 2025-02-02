//
//  InfoPageView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

import SnapKit
import Lottie

final class InfoPageView: UIView {
    
    // MARK: - UI Component

    private let statusBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableBlack
        return view
    }()
    
    private let tabLottieAnimationView: LottieAnimationView = {
        let animation = LottieAnimationView(name: "wable_tab")
        animation.contentMode = .scaleToFill
        animation.loopMode = .loop
        animation.play()
        return animation
    }()
  
    let segmentedControl: WableSegmentedControl = {
        let segmentedControl = WableSegmentedControl(items: ["경기", "순위", "뉴스", "공지사항"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    let segmentDivisionLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    let pageViewContainer: UIView = UIView()
    
    let bottomDivisionLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Method

private extension InfoPageView {
    func setupView() {
        backgroundColor = .wableWhite
        
        addSubviews(
            statusBarBackgroundView,
            tabLottieAnimationView,
            segmentedControl,
            segmentDivisionLine,
            pageViewContainer,
            bottomDivisionLine
        )
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        tabLottieAnimationView.snp.makeConstraints { make in
            make.top.equalTo(safeArea)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(4.adjustedH)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(tabLottieAnimationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(45.adjustedH)
        }
        
        segmentDivisionLine.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        pageViewContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentDivisionLine.snp.bottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        bottomDivisionLine.snp.makeConstraints { make in
            make.top.equalTo(pageViewContainer.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
            make.height.equalTo(1)
        }
    }
}
