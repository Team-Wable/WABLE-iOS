//
//  InfoViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

import SnapKit

final class InfoViewController: UIViewController {
    
    // MARK: - Properties
    
    var currentPage: Int = 0 {
        didSet {
            rootView.infoScrollView.isScrollEnabled = true
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            rootView.pageViewController.setViewControllers(
                [rootView.dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
            let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
            rootView.infoScrollView.setContentOffset(CGPoint(x: 0, y: -rootView.infoScrollView.contentInset.top - navigationBarHeight - statusBarHeight), animated: true)
            rootView.infoScrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - UI Components
    
    let rootView = InfoView()

    // MARK: - Life Cycles
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setDelegate()
        setAddTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - Extensions

extension InfoViewController {
    private func setUI() {
        
    }
    
    private func setHierarchy() {
    }
    
    private func setLayout() {

    }
    
    private func setDelegate() {
        rootView.pageViewController.delegate = self
        rootView.pageViewController.dataSource = self
    }
    
    private func setAddTarget() {
        rootView.segmentedControl.addTarget(self, action: #selector(changeValue(control:)), for: .valueChanged)
    }
    
    @objc
    private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex

        switch self.currentPage {
        case 0:
            AmplitudeManager.shared.trackEvent(tag: "click_gameschedule")
        case 1:
            AmplitudeManager.shared.trackEvent(tag: "click_ranking")
        default:
            break
        }
    }
}

extension InfoViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = rootView.dataViewControllers.firstIndex(of: viewController),
            index - 1 >= 0
        else { return nil }
        return rootView.dataViewControllers[index - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = rootView.dataViewControllers.firstIndex(of: viewController),
            index + 1 < rootView.dataViewControllers.count
        else { return nil }
        return rootView.dataViewControllers[index + 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            let viewController = pageViewController.viewControllers?[0],
            let index = rootView.dataViewControllers.firstIndex(of: viewController)
        else { return }
        self.currentPage = index
        rootView.segmentedControl.selectedSegmentIndex = index
    }
}
