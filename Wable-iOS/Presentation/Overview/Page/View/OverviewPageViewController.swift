//
//  OverviewPageViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import UIKit
import Combine

import SnapKit

final class OverviewPageViewController: UIViewController {
    
    // MARK: - UIComponent
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private let rootView = OverviewPageView()

    // MARK: Property

    private var viewControllers = [UIViewController]()

    private let viewModel: OverviewPageViewModel
    private let segmentDidChangeSubject = PassthroughSubject<OverviewSegment, Never>()
    private let pageSwipeCompletedSubject = PassthroughSubject<OverviewSegment, Never>()
    private let didLoadSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    
    // MARK: - Life Cycle

    init(viewModel: OverviewPageViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupPageController()
        setupNavigationBar()
        setupAction()
        setupBinding()

        // Trigger initial badge checks after bindings are set
        didLoadSubject.send(())
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
        
        pageSwipeCompletedSubject.send(segment)
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
        let useCase = viewModel.useCase
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
            .setViewControllers(
                [viewControllers[OverviewSegment.gameSchedule.rawValue]],
                direction: .forward,
                animated: false
            )
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupAction() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
    }
    
    func setupBinding() {
        let input = OverviewPageViewModel.Input(
            segmentDidChange: segmentDidChangeSubject.eraseToAnyPublisher(),
            pageSwipeCompleted: pageSwipeCompletedSubject.eraseToAnyPublisher(),
            didLoad: didLoadSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.currentSegment
            .sink { [weak self] segment in
                self?.segmentedControl.selectedSegmentIndex = segment.rawValue
            }
            .store(in: cancelBag)
        
        output.pagination
            .withUnretained(self)
            .sink { owner, value in
                owner.pageViewController.setViewControllers(
                    [owner.viewControllers[value.segment.rawValue]],
                    direction: value.direction,
                    animated: true
                )
            }
            .store(in: cancelBag)
        
        output.showBadge
            .sink { [weak self] segment in
                self?.segmentedControl.showBadge(at: segment.rawValue)
            }
            .store(in: cancelBag)

        output.hideBadge
            .sink { [weak self] segment in
                self?.segmentedControl.hideBadge(at: segment.rawValue)
            }
            .store(in: cancelBag)
    }
}

// MARK: - Action Method

private extension OverviewPageViewController {
    @objc func segmentedControlDidChange(_ sender: WableBadgeSegmentedControl) {
        guard let segment = OverviewSegment(rawValue: sender.selectedSegmentIndex) else { return }
        
        segmentDidChangeSubject.send(segment)
    }
}

// MARK: - Helper Method

private extension OverviewPageViewController {
    func index(for viewController: UIViewController) -> Int? {
        return viewControllers.firstIndex(of: viewController)
    }
}

// MARK: - Computed Property

private extension OverviewPageViewController {
    var pagingView: UIView { pageViewController.view }
    var pagingContainerView: UIView { rootView.pagingContainerView }
    var segmentedControl: WableBadgeSegmentedControl { rootView.segmentedControl }
}
