//
//  NotificationView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

import SnapKit

final class NotificationView: UIView {
    
    // MARK: - Properties
    
    var dataViewControllers: [UIViewController] {
        [self.notificationActivityViewController, self.notificationInformationViewController]
    }
    
    // MARK: - UI Components
    
    var notificationScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private var notificationContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var notificationSegmentedView: UIView = {
        let view = UIView()
        return view
    }()
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = NotificationSegmentedControl(items: ["활동", "정보"])
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
    
    let notificationActivityViewController = NotificationActivityViewController(viewModel: NotificationActivityViewModel(networkProvider: NetworkService()))
    let notificationInformationViewController = NotificationInformationViewController(viewModel: NotificationInfoViewModel())
    
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

extension NotificationView {
    private func setUI() {
        self.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(notificationScrollView)
        notificationScrollView.addSubview(notificationContentView)
        notificationContentView.addSubviews(notificationSegmentedView)
        notificationSegmentedView.addSubviews(segmentedControl,
                                      divisionLine,
                                      pageViewController.view)
    }
    
    private func setLayout() {
        notificationScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        notificationContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(notificationScrollView.snp.width)
            $0.height.equalTo(2000)
        }
        
        notificationSegmentedView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
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
