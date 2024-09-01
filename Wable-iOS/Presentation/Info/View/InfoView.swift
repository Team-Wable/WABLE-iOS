//
//  InfoView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

import SnapKit

final class InfoView: UIView {
    
    // MARK: - Properties
    
    var dataViewControllers: [UIViewController] {
        [self.infoMatchViewController, self.infoRankingViewController]
    }
    
    // MARK: - UI Components
    
    var infoScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private var infoContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var infoSegmentedView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let tabView = InfoTabView()
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = InfoSegmentedControl(items: ["경기", "순위"])
        segmentedControl.backgroundColor = .wableWhite
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.gray600,
                .font: UIFont.body2
            ], for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.wableBlack,
                .font: UIFont.body1
            ],
            for: .selected
        )
        return segmentedControl
    }()
    
    private let divisionLine = UIView().makeDivisionLine()
    
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.setViewControllers([self.dataViewControllers[0]], direction: .forward, animated: true)
        return vc
    }()
    
    let infoMatchViewController = InfoMatchViewController(viewModel: InfoMatchViewModel())
    let infoRankingViewController = InfoRankingViewController()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension InfoView {
    private func setUI() {
        self.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(infoScrollView, tabView)
        infoScrollView.addSubview(infoContentView)
        infoContentView.addSubviews(infoSegmentedView)
        infoSegmentedView.addSubviews(segmentedControl,
                                      divisionLine,
                                      pageViewController.view)
    }
    
    private func setLayout() {
        tabView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
        }
        
        infoScrollView.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
//            $0.edges.equalToSuperview()
        }
        
        infoContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(infoScrollView.snp.width)
            $0.height.equalTo(2000)
        }
        
        infoSegmentedView.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)

//            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54.adjusted)
        }
        
        divisionLine.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
        }
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(divisionLine.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height - 230.adjusted)
        }
    }
    
    private func setDelegate() {
        
    }
}
