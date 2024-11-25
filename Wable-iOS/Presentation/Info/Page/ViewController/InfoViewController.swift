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
    
    private var viewControllers = [UIViewController]()
    
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
        
        setupViewControllers()
        setupPageViewController()
        setupNavigationBar()
        setupAction()
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

// MARK: - InfoNewsViewControllerDelegate

extension InfoViewController: InfoNewsViewControllerDelegate {
    func pushToNewsDetailView(with news: NewsDTO) {
        pushToDetailView(
            navigationTitle: "뉴스",
            title: news.title,
            text: news.text,
            time: news.time,
            imageURLString: news.imageURLString,
            isButtonHidden: true
        )
    }
}

// MARK: - InfoNoticeViewControllerDelegate

extension InfoViewController: InfoNoticeViewControllerDelegate {
    func pushToNoticeDetailView(with notice: NoticeDTO) {
        pushToDetailView(
            navigationTitle: "공지사항",
            title: notice.title,
            text: notice.text,
            time: notice.time,
            imageURLString: notice.imageURLString,
            isButtonHidden: false
        )
    }
}

// MARK: - Private Method

private extension InfoViewController {
    func setupViewControllers() {
        viewControllers.append(InfoMatchViewController(viewModel: InfoMatchViewModel()))
        viewControllers.append(InfoRankingViewController(viewModel: InfoRankingViewModel()))
        
        let newsViewController = InfoNewsViewController(viewModel: InfoNewsViewModel())
        newsViewController.delegate = self
        viewControllers.append(newsViewController)
        
        let noticeViewController = InfoNoticeViewController(viewModel: InfoNoticeViewModel())
        noticeViewController.delegate = self
        viewControllers.append(noticeViewController)
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
        guard !viewControllers.isEmpty else { return }
        
        let selectedIndex = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers([viewControllers[selectedIndex]], direction: direction, animated: true)
        currentIndex = selectedIndex
        trackPageChangeEvent(for: currentIndex)
    }
    
    func updateSegmentedControl() {
        rootView.segmentedControl.selectedSegmentIndex = currentIndex
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
    
    func pushToDetailView(
        navigationTitle: String,
        title: String,
        text: String,
        time: String,
        imageURLString: String?,
        isButtonHidden: Bool
    ) {
        let detailViewController = InfoDetailViewController(
            configuration: .init(
                navigationTitle: navigationTitle,
                title: title,
                text: text,
                time: time,
                imageURLString: imageURLString,
                isButtonHidden: isButtonHidden
            )
        )
        detailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
