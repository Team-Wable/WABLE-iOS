//
//  NotificationPageViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/13/25.
//

import UIKit
import Combine

import SnapKit

final class NotificationPageViewController: UIViewController {
    
    // MARK: - Property
    
    private var viewControllers = [UIViewController]()

    private let viewModel: NotificationPageViewModel
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private let currentIndexSubject = CurrentValueSubject<Int, Never>(0)
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    private let rootView = NotificationPageView()
    
    // MARK: - Initializer
    
    init(viewModel: NotificationPageViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupPageViewController()
        setupNavigationBar()
        setupAction()
        
        viewDidLoadSubject.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
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
              let index = viewControllers.firstIndex(of: visibleViewController)
        else {
            return
        }
        
        currentIndexSubject.send(index)
        rootView.segmentedControl.selectedSegmentIndex = index
    }
}

// MARK: - UIPageViewControllerDataSource

extension NotificationPageViewController: UIPageViewControllerDataSource {
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

// MARK: - NotificationActivityViewControllerDelegate

extension NotificationPageViewController: NotificationActivityViewControllerDelegate {
    func pushWriteFeedViewController() {
        let writeViewController = WriteViewController(
            viewModel: WriteViewModel(networkProvider: NetworkService())
        )
        writeViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(writeViewController, animated: true)
    }
    
    func pushFeedDetailViewController(_ homeFeed: HomeFeedDTO, contentID: Int) {
        let detailViewController = FeedDetailViewController(
            viewModel: FeedDetailViewModel(networkProvider: NetworkService()),
            likeViewModel: LikeViewModel(networkProvider: NetworkService())
        )
        detailViewController.getFeedData(data: homeFeed)
        detailViewController.viewModel.contentIDSubject.send(contentID)
        detailViewController.memberId = homeFeed.memberID
        detailViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func moveMyProfileViewController() {
        navigationController?.tabBarController?.selectedIndex = 3
    }
    
    func pushOtherProfileViewController(_ userID: Int) {
        let viewController = MyPageViewController(
            viewModel: MyPageViewModel(networkProvider: NetworkService()),
            likeViewModel: LikeViewModel(networkProvider: NetworkService())
        )
        viewController.memberId = userID
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Private Method

private extension NotificationPageViewController {
    func setupViewControllers() {
        let activiyViewController = NotificationActivityViewController(
            viewModel: NotificationActivityViewModel(
                networkProvider: NetworkService()
            )
        )
        activiyViewController.delegate = self
        viewControllers.append(activiyViewController)
        
        let informationViewController = NotificationInformationViewController(
            viewModel: NotificationInfoViewModel()
        )
        viewControllers.append(informationViewController)
    }
    
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
        title = StringLiterals.Notification.notificationNavigationTitle
        
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.body1]
    }
    
    func setupAction() {
        rootView.segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
    }
    
    @objc
    func segmentedControlDidChange(_ sender: UISegmentedControl) {
        let currentIndex = currentIndexSubject.value
        let selectedIndex = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers(
            [viewControllers[selectedIndex]],
            direction: direction,
            animated: true
        ) { [weak self] isCompleted in
            guard isCompleted else { return }
            
            self?.currentIndexSubject.send(selectedIndex)
        }
    }
    
    func setupBinding() {
        let input = NotificationPageViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            currentIndex: currentIndexSubject.eraseToAnyPublisher()
        )
        
        let _ = viewModel.transform(from: input, cancelBag: cancelBag)
    }
}
