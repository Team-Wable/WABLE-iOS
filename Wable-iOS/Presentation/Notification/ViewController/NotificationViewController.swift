//
//  NotificationViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

final class NotificationViewController: UIViewController {
    
    // MARK: - Property
    
    var currentPage: Int = 0 {
        didSet {
            rootView.notificationScrollView.isScrollEnabled = true
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            rootView.pageViewController.setViewControllers(
                [rootView.dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
            let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
            rootView.notificationScrollView.setContentOffset(CGPoint(x: 0, y: -rootView.notificationScrollView.contentInset.top - navigationBarHeight - statusBarHeight), animated: true)
            rootView.notificationScrollView.isScrollEnabled = true
        }
    }
    
    private let rootView = NotificationView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDelegate()
        setupAction()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = StringLiterals.Notification.notificationNavigationTitle
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = .wableWhite
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.wableBlack]
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    deinit {
        removeObservers()
    }
}

// MARK: - UIPageViewControllerDataSource

extension NotificationViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = rootView.dataViewControllers.firstIndex(of: viewController),
              index - 1 >= 0
        else {
            return nil
        }
        
        return rootView.dataViewControllers[index - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = rootView.dataViewControllers.firstIndex(of: viewController),
              index + 1 < rootView.dataViewControllers.count
        else {
            return nil
        }
        
        return rootView.dataViewControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension NotificationViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard let viewController = pageViewController.viewControllers?[0],
              let index = rootView.dataViewControllers.firstIndex(of: viewController)
        else {
            return
        }
        
        self.currentPage = index
        rootView.segmentedControl.selectedSegmentIndex = index
        
        switch self.currentPage {
        case 0:
            AmplitudeManager.shared.trackEvent(tag: "click_activitiesnoti")
        case 1:
            AmplitudeManager.shared.trackEvent(tag: "click_infonoti")
        default:
            break
        }
    }
}

// MARK: - Private Method

private extension NotificationViewController {
    func setupDelegate() {
        rootView.pageViewController.delegate = self
        rootView.pageViewController.dataSource = self
    }
    
    func setupAction() {
        rootView.segmentedControl.addTarget(self, action: #selector(changeValue(control:)), for: .valueChanged)
    }
    
    func addObservers() {
        let notifications: [(Notification.Name, Selector)] = [
            (.didRequestPushDetailViewController, #selector(handlePushDetailViewController(_:))),
            (.didRequestPushWriteFeedViewController, #selector(handleWriteFeedViewController(_:)))
        ]
        
        notifications.forEach { name, selector in
            NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
        }
    }
    
    func removeObservers() {
        let notificationNames: [Notification.Name] = [
            .didRequestPushDetailViewController,
            .didRequestPushWriteFeedViewController
        ]
        
        notificationNames.forEach { name in
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
        }
    }
    
    @objc
    func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
        
        switch self.currentPage {
        case 0:
            AmplitudeManager.shared.trackEvent(tag: "click_activitiesnoti")
        case 1:
            AmplitudeManager.shared.trackEvent(tag: "click_infonoti")
        default:
            break
        }
    }
    
    @objc
    func handlePushDetailViewController(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let data = userInfo["data"] as? HomeFeedDTO,
              let contentID = userInfo["contentID"] as? Int
        else {
            return
        }
        
        let detailViewController = FeedDetailViewController(
            viewModel: FeedDetailViewModel(networkProvider: NetworkService()),
            likeViewModel: LikeViewModel(networkProvider: NetworkService())
        )
        detailViewController.getFeedData(data: data)
        detailViewController.contentId = contentID
        detailViewController.memberId = data.memberID
        detailViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    @objc
    func handleWriteFeedViewController(_ notification: Notification) {
        let writeViewController = WriteViewController(
            viewModel: WriteViewModel(networkProvider: NetworkService())
        )
        writeViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(writeViewController, animated: true)
    }
}
