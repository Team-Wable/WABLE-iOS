//
//  InfoPageViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit
import Combine

import SnapKit

final class InfoPageViewController: UIViewController {

    // MARK: - Property
    
    private var viewControllers = [UIViewController]()

    private let infoPageViewModel: InfoPageViewModel
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    private let currentIndexSubject = CurrentValueSubject<Int, Never>(0)
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    private let rootView = InfoPageView()
    
    // MARK: - Initializer
    
    init(infoPageViewModel: InfoPageViewModel) {
        self.infoPageViewModel = infoPageViewModel
        
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
        setupBinding()
        
        viewDidLoadSubject.send(())
    }
}

// MARK: - UIPageViewControllerDelegate

extension InfoPageViewController: UIPageViewControllerDelegate {
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

extension InfoPageViewController: UIPageViewControllerDataSource {
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

extension InfoPageViewController: InfoNewsViewControllerDelegate {
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

extension InfoPageViewController: InfoNoticeViewControllerDelegate {
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

private extension InfoPageViewController {
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
        let logoView = InfoPageLogoView()
        let logoContainer = UIBarButtonItem(customView: logoView)
        
        navigationItem.leftBarButtonItem = logoContainer
        navigationController?.navigationBar.backgroundColor = .wableBlack
    }
    
    func setupAction() {
        rootView.segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
    }
    
    @objc
    func segmentedControlDidChange(_ sender: WableSegmentedControl) {
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
    
    func setupBinding() {
        let input = InfoPageViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            currentIndex: currentIndexSubject.eraseToAnyPublisher()
        )
        
        let output = infoPageViewModel.transform(from: input, cancelBag: cancelBag)
        
        output.showBadges
            .receive(on: RunLoop.main)
            .sink { [weak self] isNewsBadgeShown, isNoticeBadgeShown in
                if isNewsBadgeShown {
                    self?.rootView.segmentedControl.showBadge(at: Constants.newsIndexNumber)
                }
                
                if isNoticeBadgeShown {
                    self?.rootView.segmentedControl.showBadge(at: Constants.noticeIndexNumber)
                }
            }
            .store(in: cancelBag)
        
        output.hideNewsBadge
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.rootView.segmentedControl.hideBadge(at: Constants.newsIndexNumber)
            }
            .store(in: cancelBag)
        
        output.hideNoticeBadge
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.rootView.segmentedControl.hideBadge(at: Constants.noticeIndexNumber)
            }
            .store(in: cancelBag)
    }
}

private extension InfoPageViewController {
    
    // MARK: - Constants
    
    enum Constants {
        static let newsIndexNumber = 2
        static let noticeIndexNumber = 3
    }

}
