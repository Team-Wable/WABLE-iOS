//
//  OverviewPageViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import UIKit

import SnapKit

final class OverviewPageViewController: UIViewController {
    
    // MARK: - Property
    
    private var currentIndex = 0 {
        didSet {
            guard oldValue != currentIndex else { return }
            trackPageChangeEvent(for: currentIndex)
        }
    }
    private var viewControllers = [UIViewController]()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private let rootView = OverviewPageView()
    
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

extension OverviewPageViewController: UIPageViewControllerDelegate {
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

extension OverviewPageViewController: UIPageViewControllerDataSource {
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

// MARK: - NoticeViewControllerDelegate

extension OverviewPageViewController: NoticeViewControllerDelegate {
    func navigateToNoticeDetail(with news: Announcement) {
        let date = news.createdDate ?? Date()
        let detailViewController = AnnouncementDetailViewController().then {
            $0.configure(
                type: .notice,
                title: news.title,
                time: date.elapsedText,
                imageURL: news.imageURL,
                bodyText: news.text
            )
        }
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - Setup Method

private extension OverviewPageViewController {
    func setupViewControllers() {
        let useCase = OverviewUseCaseImpl()
        
        let gameScheduleViewController = GameScheduleListViewController(viewModel: .init(useCase: useCase))
        
        let rankViewController = RankListViewController(viewModel: .init(useCase: useCase))
        
        let curationViewController = CurationViewController(viewModel: .init(useCase: useCase))
        curationViewController.onCellTap = { UIApplication.shared.open($0) }
        
        let noticeViewController = NoticeViewController(viewModel: .init(useCase: useCase))
        noticeViewController.delegate = self
        
        [
            gameScheduleViewController,
            rankViewController,
            curationViewController,
            noticeViewController
        ].forEach {
            viewControllers.append($0)
        }
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
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
    }
}

// MARK: - Action Method

private extension OverviewPageViewController {
    @objc func segmentedControlDidChange(_ sender: WableBadgeSegmentedControl) {
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

// MARK: - Helper Method

private extension OverviewPageViewController {
    func index(for viewController: UIViewController) -> Int? {
        return viewControllers.firstIndex(of: viewController)
    }
    
    func trackPageChangeEvent(for index: Int) {
        switch index {
        case 0:
            AmplitudeManager.shared.trackEvent(tag: .clickGameschedule)
        case 1:
            AmplitudeManager.shared.trackEvent(tag: .clickRanking)
        case 2:
            
            // TODO: 추후 큐레이션으로 교체 예정
            
            AmplitudeManager.shared.trackEvent(tag: .clickNews)
        case 3:
            AmplitudeManager.shared.trackEvent(tag: .clickAnnouncement)
        default:
            break
        }
    }
}

// MARK: - Computed Property

private extension OverviewPageViewController {
    var pagingView: UIView { pageViewController.view }
    var pagingContainerView: UIView { rootView.pagingContainerView }
    var segmentedControl: WableBadgeSegmentedControl { rootView.segmentedControl }
}
