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
    
    private lazy var deleteReplyButtonTapped = deletePopupView?.confirmButton.publisher(for: .touchUpInside).map { _ in
        return self.commentId
    }.eraseToAnyPublisher()
    
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    var ghostReason: String = ""
    
    var contentId: Int = 0
    var commentId: Int = 0
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
    private var welcomePopupView: WablePopupView? = nil
    private var photoDetailView: WablePhotoDetailView?
    
    private var reportToastView: UIImageView?
    
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
        viewModel.viewDidLoad.send()
        print("\(KeychainWrapper.loadToken(forKey: "accessToken") ?? "") 🩵🩵🩵")
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
        
        if loadUserData()?.isFirstUser == true {
            self.welcomePopupView = WablePopupView(popupTitle: StringLiterals.Home.homeWelcomePopupTitle,
                                                   popupContent: "\(loadUserData()?.userNickname ?? "")" + StringLiterals.Home.homeWelcomePopupContent,
                                                   singleButtonTitle: StringLiterals.Home.homeWelcomePopupButtonTitle)
            
            if let popupView = self.welcomePopupView {
                if let window = UIApplication.shared.keyWindowInConnectedScenes {
                    window.addSubviews(popupView)
                }
                
                popupView.delegate = self
                
                popupView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            }
        }
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
    }
    
    private func removeNotification() {
        
    }
    
    private func bindViewModel() {
        
        viewModel.pushViewController
            .sink { [weak self] index in
                self?.navigationController?.isNavigationBarHidden = false
                let feedDetailViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
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
                DispatchQueue.main.async {
                    self?.homeView.feedTableView.reloadData()
                }
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
    
    @objc
    func removePhotoButtonTapped() {
        self.photoDetailView?.removeFromSuperview()
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
            .map { _ in return (isClicked, contentId) }
            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
            .eraseToAnyPublisher()
        
        let input = LikeViewModel.Input(likeButtonTapped: likeButtonTapped, commentLikeButtonTapped: nil, deleteButtonDidTapped: deleteButtonTapped, deleteReplyButtonDidTapped: deleteReplyButtonTapped)
        
        let output = self.likeViewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.toggleLikeButton
            .sink { _ in }
            .store(in: self.cancelBag)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("viewModel.feedDatas.count: \(viewModel.feedDatas.count)")
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
        cell.alarmTriggerdId = viewModel.feedDatas[indexPath.row].contentID ?? Int()
        
        cell.bind(data: viewModel.feedDatas[indexPath.row])
        
        if viewModel.feedDatas[indexPath.row].memberID == loadUserData()?.memberId {
            cell.bottomView.ghostButton.isHidden = true
            
            cell.menuButtonTapped = {
                self.homeBottomsheetView.showSettings()
                self.homeBottomsheetView.deleteButton.isHidden = false
                self.homeBottomsheetView.reportButton.isHidden = true
                
                self.homeBottomsheetView.deleteButton.addTarget(self, action: #selector(self.deletePostButtonTapped), for: .touchUpInside)
                self.contentId = self.viewModel.feedDatas[indexPath.row].contentID ?? Int()
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
                self.relateText = self.viewModel.feedDatas[indexPath.row].contentText ?? ""
                self.homeBottomsheetView.reportButton.addTarget(self, action: #selector(self.reportButtonTapped), for: .touchUpInside)
                self.nowShowingPopup = "report"
            }
        }
        
        var memberGhost = self.viewModel.feedDatas[indexPath.row].memberGhost
        memberGhost = adjustGhostValue(memberGhost)
        
        cell.grayView.layer.zPosition = 1
        
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
            self.postLikeButtonAPI(isClicked: cell.bottomView.isLiked, contentId: self.viewModel.feedDatas[indexPath.row].contentID ?? 0)
            
            cell.bottomView.isLiked.toggle()
        }
        
        cell.contentImageViewTapped = { [weak self] in
            DispatchQueue.main.async {
                self?.photoDetailView = WablePhotoDetailView()
                
                if let window = UIApplication.shared.keyWindowInConnectedScenes {
                    window.addSubview(self?.photoDetailView ?? WablePhotoDetailView())
                    
                    self?.photoDetailView?.removePhotoButton.addTarget(self, action: #selector(self?.removePhotoButtonTapped), for: .touchUpInside)
                    
                    if let imageURL = self?.viewModel.feedDatas[indexPath.row].contentImageURL {
                        self?.photoDetailView?.photoImageView.loadContentImage(url: imageURL) { image in
                            // 이미지 로드가 완료된 후, 동적으로 높이 변경
                            self?.photoDetailView?.updateImageViewHeight(with: image)
                        }
                    }
                    
                    self?.photoDetailView?.snp.makeConstraints {
                        $0.edges.equalToSuperview()
                    }
                }
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
        detailViewController.hidesBottomBarWhenPushed = true
        detailViewController.getFeedData(data: viewModel.feedDatas[indexPath.row])
        detailViewController.contentId = viewModel.feedDatas[indexPath.row].contentID ?? Int()
        detailViewController.memberId = viewModel.feedDatas[indexPath.row].memberID
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension HomeViewController: WablePopupDelegate {
    
    func cancleButtonTapped() {
        if nowShowingPopup == "ghost" {
            self.ghostPopupView?.removeFromSuperview()
        }
        
        if nowShowingPopup == "report" {
            self.reportPopupView?.removeFromSuperview()
        }
        
        if nowShowingPopup == "delete" {
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
            
            Task {
                do {
                    if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                        let result = try await self.likeViewModel.postReportButtonAPI(
                            reportTargetNickname: self.reportTargetNickname,
                            relateText: self.relateText
                        )
                        
                        self.reportToastView = UIImageView(image: ImageLiterals.Toast.toastReport)
                        self.reportToastView?.contentMode = .scaleAspectFit
                        
                        if let reportToastView = self.reportToastView {
                            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                                window.addSubviews(reportToastView)
                            }
                            
                            reportToastView.snp.makeConstraints {
                                $0.top.equalToSuperview().inset(75.adjusted)
                                $0.centerX.equalToSuperview()
                                $0.width.equalTo(343.adjusted)
                            }
                            
                            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn) {
                                self.reportToastView?.alpha = 0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.reportToastView?.removeFromSuperview()
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
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
    
    func singleButtonTapped() {
        self.welcomePopupView?.removeFromSuperview()
        
        saveUserData(UserInfo(isSocialLogined: loadUserData()?.isPushAlarmAllowed ?? false,
                              isFirstUser: false,
                              isJoinedApp: loadUserData()?.isJoinedApp ?? false,
                              userNickname: loadUserData()?.userNickname ?? "",
                              memberId: loadUserData()?.memberId ?? 0,
                              userProfileImage: loadUserData()?.userProfileImage ?? "",
                              fcmToken: loadUserData()?.fcmToken ?? "",
                              isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
    }
}
