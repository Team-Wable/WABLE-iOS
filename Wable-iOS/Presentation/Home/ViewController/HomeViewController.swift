//
//  HomeViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var writeButtonDidTapped = self.homeView.writeFeedButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
//    var feedData: [HomeFeedDTO] = []
    
    // MARK: - UI Components
    
    private let homeView = HomeView()
    private var ghostPopupView: WablePopupView? = nil
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        self.view = homeView
    }
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        setRefreshControl()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
        self.navigationController?.navigationBar.isHidden = true
        
        setNotification()
        
        viewModel.viewWillAppear.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        removeNotification()
    }
}

// MARK: - Extensions

extension HomeViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {
        homeView.feedTableView.dataSource = self
        homeView.feedTableView.delegate = self
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(showToast(_:)), name: WriteViewController.writeCompletedNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(showDeleteToast(_:)), name: DeletePopupViewController.showDeletePostToastNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(popViewController), name: DeletePopupViewController.popViewController, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPopupNotification(_:)), name: NSNotification.Name("DismissDetailView"), object: nil)
    }
    
    private func removeNotification() {
//        NotificationCenter.default.removeObserver(self, name: WriteViewController.writeCompletedNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: DeletePopupViewController.showDeletePostToastNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: DeletePopupViewController.popViewController, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("DismissDetailView"), object: nil)
    }
    
    private func bindViewModel() {
        
        viewModel.pushViewController
            .sink { [weak self] index in
                self?.navigationController?.isNavigationBarHidden = false
                let feedDetailViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()))
                feedDetailViewController.hidesBottomBarWhenPushed = true
                
                if let data = self?.viewModel.feedDatas[index] {
                    feedDetailViewController.getFeedData(data: data)
                }
                
                self?.navigationController?.pushViewController(feedDetailViewController, animated: true)
            }
            .store(in: &cancellables)
        
        writeButtonDidTapped
            .sink { [weak self] in
                self?.viewModel.pushToWriteViewControllr.send()
            }
            .store(in: &cancellables)
        
        viewModel.pushToWriteViewControllr
            .sink { [weak self] in
                let writeViewController = WriteViewController(viewModel: WriteViewModel(networkProvider: NetworkService()))
                writeViewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(writeViewController, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.homeFeedDTO
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
//                self?.feedData = data
                self?.homeView.feedTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func showGhostPopupView() {
        self.ghostPopupView = WablePopupView(popupTitle: StringLiterals.Home.ghostPopupTitle,
                                             popupContent: "",
                                             leftButtonTitle: StringLiterals.Home.ghostPopupUndo,
                                             rightButtonTitle: StringLiterals.Home.ghostPopupDo)
        
        if let popupView = self.ghostPopupView {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                window.addSubviews(popupView)
            }
            
            popupView.delegate = self
            
            popupView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    private func setRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        homeView.feedTableView.refreshControl = self.refreshControl
    }
    
    @objc
    private func didPullToRefresh() {
        print("didPullToRefresh")
        DispatchQueue.main.async {
            self.viewModel.viewWillAppear.send()
        }
        self.perform(#selector(finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    private func finishedRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    @objc func showToast(_ notification: Notification) {
        if let showToast = notification.userInfo?["showToast"] as? Bool {
            print("showToast")
            viewModel.cursor = -1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.didPullToRefresh()
                
                UIView.animate(withDuration: 0.3) {
                    self.homeView.feedTableView.contentOffset.y = 0
                }
            }
            NotificationCenter.default.removeObserver(self, name: WriteViewController.writeCompletedNotification, object: nil)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.feedDatas.count
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == homeView.feedTableView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height) {
                let lastContentID = viewModel.feedDatas.last?.contentID ?? -1
                viewModel.cursor = lastContentID
                viewModel.viewWillAppear.send()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeView.feedTableView.dequeueReusableCell(withIdentifier: HomeFeedTableViewCell.identifier, for: indexPath) as? HomeFeedTableViewCell ?? HomeFeedTableViewCell()
        cell.selectionStyle = .none
        
        cell.bind(data: viewModel.feedDatas[indexPath.row])
        
        cell.bottomView.commentButtonTapped = { [weak self] in
            self?.viewModel.commentButtonTapped.send(indexPath.row)
        }
        
        cell.bottomView.ghostButtonTapped = { [weak self] in
            self?.showGhostPopupView()
        }
        
        cell.bottomView.heartButtonTapped = { [weak self] in
            cell.bottomView.isLiked.toggle()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()))
        detailViewController.hidesBottomBarWhenPushed = true
        detailViewController.getFeedData(data: viewModel.feedDatas[indexPath.row])
        detailViewController.contentId = viewModel.feedDatas[indexPath.row].contentID
        detailViewController.memberId = viewModel.feedDatas[indexPath.row].memberID
        detailViewController.userProfileURL = viewModel.feedDatas[indexPath.row].memberProfileURL
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension HomeViewController: WablePopupDelegate {
    
    func cancleButtonTapped() {
        self.ghostPopupView?.removeFromSuperview()
    }
    
    func confirmButtonTapped() {
        self.ghostPopupView?.removeFromSuperview()
        print("투명도 버튼 클릭: 서버통신 이후에 투명도 낮추도록 하기")
    }
}
