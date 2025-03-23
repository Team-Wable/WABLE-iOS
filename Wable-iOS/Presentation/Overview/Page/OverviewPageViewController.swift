//
//  OverviewPageViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import Combine
import UIKit

import CombineCocoa
import SnapKit
import Then

final class OverviewPageViewController: UIViewController {
    
    // MARK: - UIComponent

    private let statusBarBackgroundView = UIView(backgroundColor: .wableBlack)
    
    private let navigationView = NavigationView(type: .hub(title: "소식", isBeta: false)).then {
        $0.configureView()
    }
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    
    private let underlineView = UIView(backgroundColor: .gray200)
    
    // MARK: - Property
    
    private var viewControllers = [UIViewController]()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupNavigationBar()
        setupPageController()
    }
}

// MARK: - Setup Method

private extension OverviewPageViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            statusBarBackgroundView,
            navigationView,
            pagingView,
            underlineView
        )
    }
    
    func setupConstraint() {
        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(60)
        }
        
        pagingView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(underlineView.snp.top)
        }
        
        underlineView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeArea)
            make.adjustedHeightEqualTo(1)
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupPageController() {
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pagingView.backgroundColor = .error
    }
}

// MARK: - Computed Property

private extension OverviewPageViewController {
    var pagingView: UIView {
        return pageViewController.view
    }
}
