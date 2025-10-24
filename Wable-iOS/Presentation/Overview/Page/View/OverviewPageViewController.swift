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

    private var currentSegment: OverviewSegment = .gameSchedule {
        didSet {
            guard oldValue != currentSegment else { return }
            trackPageChangeEvent(for: currentSegment)
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
              let index = index(for: visibleViewController),
              let segment = OverviewSegment(rawValue: index)
        else {
            return
        }
        
        currentSegment = segment
        segmentedControl.selectedSegmentIndex = currentSegment.rawValue
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
        
        pageViewController
            .setViewControllers([viewControllers[currentSegment.rawValue]], direction: .forward, animated: false)
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
        guard let segment = OverviewSegment(rawValue: sender.selectedSegmentIndex) else { return }
        let direction: UIPageViewController.NavigationDirection = segment.rawValue > currentSegment.rawValue ? .forward : .reverse
        
        pageViewController.setViewControllers(
            [viewControllers[segment.rawValue]],
            direction: direction,
            animated: true
        ) { [unowned self] _ in
            currentSegment = segment
        }
    }
}

// MARK: - Helper Method

private extension OverviewPageViewController {
    func index(for viewController: UIViewController) -> Int? {
        return viewControllers.firstIndex(of: viewController)
    }
    
    func trackPageChangeEvent(for segment: OverviewSegment) {
        switch segment {
        case .gameSchedule:
            AmplitudeManager.shared.trackEvent(tag: .clickGameschedule)
        case .teamRank:
            AmplitudeManager.shared.trackEvent(tag: .clickRanking)
        case .curation:
            AmplitudeManager.shared.trackEvent(tag: .clickNews)
        case .notice:
            AmplitudeManager.shared.trackEvent(tag: .clickAnnouncement)
        }
    }
}

// MARK: - Computed Property

private extension OverviewPageViewController {
    var pagingView: UIView { pageViewController.view }
    var pagingContainerView: UIView { rootView.pagingContainerView }
    var segmentedControl: WableBadgeSegmentedControl { rootView.segmentedControl }
}
