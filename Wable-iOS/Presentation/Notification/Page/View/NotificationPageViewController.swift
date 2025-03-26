//
//  NotificationPageViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/19/25.
//

import UIKit

import SnapKit
import Then

final class NotificationPageViewController: UIViewController {
    
    // MARK: - Property

    private var currentIndex = 0
    private var viewControllers = [UIViewController]()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private let rootView = NotificationPageView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupPageController()
        setupNavigationBar()
        setupAction()
    }
}

// MARK: - UIPageViewControllerDelegate

extension NotificationPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let visibleViewController = pageViewController.viewControllers?.first,
              let index = index(for: visibleViewController)
        else {
            return
        }
        
        currentIndex = index
        segmentedControl.selectedSegmentIndex = currentIndex
    }
}

// MARK: - UIPageViewControllerDataSource

extension NotificationPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(for: viewController),
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
        guard let index = index(for: viewController),
              index < viewControllers.count - 1
        else {
            return nil
        }
        
        return viewControllers[index + 1]
    }
}

// MARK: - Setup Method

private extension NotificationPageViewController {
    func setupViewControllers() {
        
    }
    
    func setupPageController() {
        addChild(pageViewController)
        
        pagingContainerView.addSubview(pagingView)
        pagingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageViewController.didMove(toParent: self)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        pageViewController.setViewControllers([viewControllers[currentIndex]], direction: .forward, animated: false)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupAction() {
        navigationView.backButton.addTarget(self, action: #selector(backButtoDidTap), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
    }
}

// MARK: - Helper Method

private extension NotificationPageViewController {
    func index(for viewController: UIViewController) -> Int? {
        return viewControllers.firstIndex(of: viewController)
    }
}

// MARK: - Action Method

private extension NotificationPageViewController {
    @objc func backButtoDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func segmentedControlDidChange(_ sender: WableSegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = selectedSegmentIndex > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers(
            [viewControllers[selectedSegmentIndex]],
            direction: direction,
            animated: true
        ) { [unowned self] _ in
            currentIndex = selectedSegmentIndex
        }
    }
}

// MARK: - Computed Property

private extension NotificationPageViewController {
    var pagingView: UIView { pageViewController.view }
    var navigationView: NavigationView { rootView.navigationView }
    var segmentedControl: WableSegmentedControl { rootView.segmentedControl }
    var pagingContainerView: UIView { rootView.pagingContainerView }
}
