//
//  HomeViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import Combine
import SafariServices
import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cancelBag = CancelBag()
    private let viewModel: HomeViewModel
    private let likeViewModel: LikeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var writeButtonDidTapped = self.homeView.writeFeedButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var deleteButtonTapped = deletePopupView?.confirmButton.publisher(for: .touchUpInside).map { _ in
        return self.contentId
    }.eraseToAnyPublisher()
    
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    var ghostReason: String = ""
    
    var contentId: Int = 0
    var reportTargetNickname: String = ""
    var relateText: String = ""
    let warnUserURL = URL(string: StringLiterals.Network.warnUserGoogleFormURL)
    
    var nowShowingPopup: String = ""
    
//    var feedData: [HomeFeedDTO] = []
    
    // MARK: - UI Components
    
    let homeView = HomeView()
    private var ghostPopupView: WablePopupView? = nil
    private let refreshControl = UIRefreshControl()
    
    var homeBottomsheetView = HomeBottomSheetView()
    private var reportPopupView: WablePopupView? = nil
    private var deletePopupView: WablePopupView? = nil
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        self.view = homeView
    }
    
    init(viewModel: HomeViewModel, likeViewModel: LikeViewModel) {
        self.viewModel = viewModel
        self.likeViewModel = likeViewModel
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
            UIView.animate(withDuration: 0.3) {
                self.homeView.feedTableView.contentOffset.y = 0
            }
            NotificationCenter.default.removeObserver(self, name: WriteViewController.writeCompletedNotification, object: nil)
        }
    }
    
    @objc
    func deletePostButtonTapped() {
        popBottomsheetView()
        
        self.deletePopupView = WablePopupView(popupTitle: StringLiterals.Home.deletePopupTitle,
                                              popupContent: StringLiterals.Home.deletePopupContent,
                                              leftButtonTitle: StringLiterals.Home.deletePopupUndo,
                                              rightButtonTitle: StringLiterals.Home.deletePopupDo)
        
        if let popupView = self.deletePopupView {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                window.addSubviews(popupView)
            }
            
            popupView.delegate = self
            
            popupView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    @objc
    func reportButtonTapped() {
        popBottomsheetView()
        
        self.reportPopupView = WablePopupView(popupTitle: StringLiterals.Home.reportPopupTitle,
                                              popupContent: StringLiterals.Home.reportPopupContent,
                                              leftButtonTitle: StringLiterals.Home.reportPopupUndo,
                                              rightButtonTitle: StringLiterals.Home.reportPopupDo)
        
        if let popupView = self.reportPopupView {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                window.addSubviews(popupView)
            }
            
            popupView.delegate = self
            
            popupView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    func popBottomsheetView() {
        if UIApplication.shared.keyWindowInConnectedScenes != nil {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.homeBottomsheetView.dimView.alpha = 0
                if let window = UIApplication.shared.keyWindowInConnectedScenes {
                    self.homeBottomsheetView.bottomsheetView.frame = CGRect(x: 0, y: window.frame.height, width: self.homeBottomsheetView.frame.width, height: self.homeBottomsheetView.bottomsheetView.frame.height)
                }
            })
            homeBottomsheetView.dimView.removeFromSuperview()
            homeBottomsheetView.bottomsheetView.removeFromSuperview()
        }
    }
}

// MARK: - Network

extension HomeViewController {
    private func postLikeButtonAPI(isClicked: Bool, contentId: Int) {
        // 최초 한 번만 publisher 생성
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?  = Just(())
                .map { _ in return (!isClicked, contentId) }
                .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
                .eraseToAnyPublisher()
        
        let input = LikeViewModel.Input(likeButtonTapped: likeButtonTapped, deleteButtonDidTapped: deleteButtonTapped)

        let output = self.likeViewModel.transform(from: input, cancelBag: self.cancelBag)

        output.toggleLikeButton
            .sink { _ in }
            .store(in: self.cancelBag)
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
        
        cell.alarmTriggerType = "contentGhost"
        cell.targetMemberId = viewModel.feedDatas[indexPath.row].memberID
        cell.alarmTriggerdId = viewModel.feedDatas[indexPath.row].contentID
        
        cell.profileImageView.load(url: "\(viewModel.feedDatas[indexPath.row].memberProfileURL)")
        cell.bind(data: viewModel.feedDatas[indexPath.row])
        
        if viewModel.feedDatas[indexPath.row].memberID == loadUserData()?.memberId {
            cell.bottomView.ghostButton.isHidden = true
            
            cell.menuButtonTapped = {
                self.homeBottomsheetView.showSettings()
                self.homeBottomsheetView.deleteButton.isHidden = false
                self.homeBottomsheetView.reportButton.isHidden = true
                
                self.homeBottomsheetView.deleteButton.addTarget(self, action: #selector(self.deletePostButtonTapped), for: .touchUpInside)
                self.contentId = self.viewModel.feedDatas[indexPath.row].contentID
                self.nowShowingPopup = "delete"
            }
        } else {
            // 다른 유저인 경우
            cell.bottomView.ghostButton.isHidden = false
            
            cell.menuButtonTapped = {
                self.homeBottomsheetView.showSettings()
                self.homeBottomsheetView.reportButton.isHidden = false
                self.homeBottomsheetView.deleteButton.isHidden = true
                
                self.reportTargetNickname = self.viewModel.feedDatas[indexPath.row].memberNickname
                self.relateText = self.viewModel.feedDatas[indexPath.row].contentText
                self.homeBottomsheetView.reportButton.addTarget(self, action: #selector(self.reportButtonTapped), for: .touchUpInside)
                self.nowShowingPopup = "report"
            }
        }
        
        var memberGhost = self.viewModel.feedDatas[indexPath.row].memberGhost
        memberGhost = adjustGhostValue(memberGhost)
        
        cell.grayView.layer.zPosition = 1
//        print("isGhost: \(self.viewModel.feedDatas[indexPath.row].isGhost)")
//        print("memberGhost: \(self.viewModel.feedDatas[indexPath.row].memberGhost)")
        
        // 내가 투명도를 누른 유저인 경우 -85% 적용
        if self.viewModel.feedDatas[indexPath.row].isGhost {
            cell.grayView.alpha = 0.85
        } else {
            cell.grayView.alpha = CGFloat(Double(-memberGhost) / 100)
        }
        
        // 탈퇴한 회원 닉네임 텍스트 색상 변경, 프로필로 이동 못하도록 적용
//        if self.viewModel.feedDatas[indexPath.row].isDeleted {
//            cell.nicknameLabel.textColor = .donGray12
//            cell.profileImageView.isUserInteractionEnabled = false
//        } else {
//            cell.nicknameLabel.textColor = .donBlack
//            cell.profileImageView.isUserInteractionEnabled = true
//        }
        
        cell.profileButtonAction = {
            let memberId = self.viewModel.feedDatas[indexPath.row].memberID

            if memberId == loadUserData()?.memberId ?? 0  {
                self.tabBarController?.selectedIndex = 3
            } else {
                let viewController = MyPageViewController(viewModel: MyPageViewModel(networkProvider: NetworkService()))
                viewController.memberId = memberId
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        cell.bottomView.ghostButtonTapped = { [weak self] in
            self?.alarmTriggerType = cell.alarmTriggerType
            self?.targetMemberId = cell.targetMemberId
            self?.alarmTriggerdId = cell.alarmTriggerdId
            self?.showGhostPopupView()
            self?.nowShowingPopup = "ghost"
        }
        
        cell.bottomView.heartButtonTapped = {
            var currentHeartCount = cell.bottomView.heartButton.titleLabel?.text
            
            if cell.bottomView.isLiked == true {
                cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) - 1)", font: .caption1, textColor: .wableBlack)
            } else {
                cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) + 1)", font: .caption1, textColor: .wableBlack)
            }
            cell.bottomView.isLiked.toggle()
            self.postLikeButtonAPI(isClicked: cell.bottomView.isLiked, contentId: self.viewModel.feedDatas[indexPath.row].contentID)
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
        if ghostPopupView != nil {
            self.ghostPopupView?.removeFromSuperview()
        }
        
        if reportPopupView != nil {
            self.reportPopupView?.removeFromSuperview()
        }
        
        if deletePopupView != nil {
            self.deletePopupView?.removeFromSuperview()
        }
    }
    
    func confirmButtonTapped() {
        if nowShowingPopup == "ghost" {
            self.ghostPopupView?.removeFromSuperview()
            
            Task {
                do {
                    if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                        let result = try await self.likeViewModel.postDownTransparency(
                            accessToken: accessToken,
                            alarmTriggerType: self.alarmTriggerType,
                            targetMemberId: self.targetMemberId,
                            alarmTriggerId: self.alarmTriggerdId,
                            ghostReason: self.ghostReason
                        )
                        
                        didPullToRefresh()
                        
                        if result?.status == 400 {
                            // 이미 투명도를 누른 대상인 경우, 토스트 메시지 보여주기
//                            showAlreadyTransparencyToast()
                            print("이미 투명도를 누른 대상인 경우, 토스트 메시지 보여주기")
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        if nowShowingPopup == "report" {
            self.reportPopupView?.removeFromSuperview()
            
            let warnView: SFSafariViewController
            if let warnURL = self.warnUserURL {
                warnView = SFSafariViewController(url: warnURL)
                self.present(warnView, animated: true, completion: nil)
            }
            
//            Task {
//                do {
//                    if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
//                        let result = try await self.homeViewModel.postReportButtonAPI(
//                            reportTargetNickname: self.reportTargetNickname,
//                            relateText: self.relateText
//                        )
//                    }
//                } catch {
//                    print(error)
//                }
//            }
        }
        
        if nowShowingPopup == "delete" {
            self.deletePopupView?.removeFromSuperview()
            
            Task {
                do {
                    if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                        let result = try await self.likeViewModel.deletePostAPI(accessToken: accessToken, contentId: self.contentId)
                        
                        didPullToRefresh()
                        
                        UIView.animate(withDuration: 0.3) {
                            self.homeView.feedTableView.contentOffset.y = 0
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
