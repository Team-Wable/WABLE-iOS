//
//  InfoViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

import SnapKit

final class InfoViewController: UIViewController {

    // MARK: - Property
    
    private var currentIndex = 0
    
    private let viewControllers: [UIViewController] = [
        InfoMatchViewController(viewModel: InfoMatchViewModel()),
        InfoRankingViewController()
    ]
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    
    private let rootView = InfoView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageViewController()
        setupNavigationBar()
        setupAction()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateStatusBarHeightConstraint()
    }
}

// MARK: - UIPageViewControllerDelegate

extension InfoViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let visibleViewController = pageViewController.viewControllers?.first,
              let index = viewControllers.firstIndex(of: visibleViewController)
        else {
            return
        }
        
        currentIndex = index
        updateSegmentedControl()
        trackPageChangeEvent(for: currentIndex)
    }
}

// MARK: - UIPageViewControllerDataSource

extension InfoViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController),
              index > 0
        else {
            return nil
        }
        
        return viewControllers[index - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController),
              index < viewControllers.count - 1
        else {
            return nil
        }
        
        return viewControllers[index + 1]
    }
}

// MARK: - Private Method

private extension InfoViewController {
    func setupPageViewController() {
        addChild(pageViewController)
        
        rootView.pageViewContainer.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageViewController.didMove(toParent: self)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        guard let firstViewController = viewControllers.first else { return }
        pageViewController.setViewControllers([firstViewController], direction: .forward, animated: false)
    }
    
    func setupNavigationBar() {
        let logoView = InfoLogoView()
        let logoContainer = UIBarButtonItem(customView: logoView)
        
        navigationItem.leftBarButtonItem = logoContainer
        navigationController?.navigationBar.backgroundColor = .wableBlack
    }
    
    func setupAction() {
        rootView.segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
    }
    
    @objc
    func segmentedControlDidChange(_ sender: WableSegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers([viewControllers[selectedIndex]], direction: direction, animated: true)
        currentIndex = selectedIndex
        trackPageChangeEvent(for: currentIndex)
    }
    
    func updateSegmentedControl() {
        rootView.segmentedControl.selectedSegmentIndex = currentIndex
    }
    
    func updateStatusBarHeightConstraint() {
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        rootView.statusBarBackgroundView.snp.updateConstraints { make in
            make.height.equalTo(statusBarHeight)
        }
    }
    
    func trackPageChangeEvent(for index: Int) {
        switch index {
        case 0:
            AmplitudeManager.shared.trackEvent(tag: "click_gameschedule")
        case 1:
            AmplitudeManager.shared.trackEvent(tag: "click_ranking")
        default:
            break
        }
    }
}
