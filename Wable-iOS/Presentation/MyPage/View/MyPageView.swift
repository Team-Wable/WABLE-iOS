//
//  MyPageView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/19/24.
//

import UIKit

import SnapKit

final class MyPageView: UIView {
    
    // MARK: - Properties
    
    var dataViewControllers: [UIViewController] {
        [self.myPagePostViewController, self.myPageReplyViewController]
    }
    
    // MARK: - UI Components
    
    var myPageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .wableWhite
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private var myPageContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var myPageProfileView = MyPageProfileView()
    
    private var myPageSegmentedView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableWhite
        return view
    }()
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = MyPageSegmentedControl(items: ["게시글", "댓글"])
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
    
    let divisionLine = UIView().makeDivisionLine()
    
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.setViewControllers([self.dataViewControllers[0]], direction: .forward, animated: true)
        return vc
    }()
    
    let myPagePostViewController = MyPagePostViewController(viewModel: HomeViewModel(), likeViewModel: LikeViewModel(networkProvider: NetworkService()), myPageViewModel: MyPageViewModel(networkProvider: NetworkService()))
    let myPageReplyViewController = MyPageReplyViewController(likeViewModel: LikeViewModel(networkProvider: NetworkService()), myPageViewModel: MyPageViewModel(networkProvider: NetworkService()))
    
    var myPageBottomsheet = MyPageBottomSheetView()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        setAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension MyPageView {
    private func setUI() {
        self.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(myPageScrollView)
        myPageScrollView.addSubview(myPageContentView)
        myPageContentView.addSubviews(myPageProfileView,
                                      myPageSegmentedView)
        myPageSegmentedView.addSubviews(segmentedControl,
                                        divisionLine,
                                        pageViewController.view)
    }
    
    private func setLayout() {
        myPageScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        myPageContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(myPageScrollView.snp.width)
            $0.height.equalTo(2000)
        }
        
        myPageProfileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(337.adjusted)
        }
        
        myPageSegmentedView.snp.makeConstraints {
            $0.top.equalTo(myPageProfileView.snp.bottom)
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
            $0.top.equalTo(segmentedControl.snp.bottom).offset(2.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height - 150.adjusted)
        }
    }
    
    private func setDelegate() {
        
    }
    
    private func setAddTarget() {
        
    }
}
