//
//  NotificationViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

final class NotificationViewController: UIViewController {
    
    // MARK: - Properties
    
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
    
    // MARK: - UI Components
    
    let rootView = NotificationView()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(handlePushDetailViewController(_:)), name: .didRequestPushDetailViewController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWriteFeedViewController(_:)), name: .didRequestPushWriteFeedViewController, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didRequestPushDetailViewController, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didRequestPushWriteFeedViewController, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = StringLiterals.Notification.notificationNavigationTitle
        self.navigationController?.navigationBar.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.wableBlack]
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }
}

// MARK: - Extensions

extension NotificationViewController {
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
            AmplitudeManager.shared.trackEvent(tag: "click_activitiesnoti")
        case 1:
            AmplitudeManager.shared.trackEvent(tag: "click_infonoti")
        default:
            break
        }
    }
    
    @objc private func handlePushDetailViewController(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let data = userInfo["data"] as? HomeFeedDTO,
              let contentID = userInfo["contentID"] as? Int else { return }
        
        let detailViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
        detailViewController.getFeedData(data: data)
        detailViewController.contentId = contentID
        detailViewController.memberId = data.memberID
//        detailViewController.userProfileURL = data.memberProfileURL
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    @objc private func handleWriteFeedViewController(_ notification: Notification) {
        let writeViewController = WriteViewController(viewModel: WriteViewModel(networkProvider: NetworkService()))
        writeViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(writeViewController, animated: true)

    }
    
}

extension NotificationViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
