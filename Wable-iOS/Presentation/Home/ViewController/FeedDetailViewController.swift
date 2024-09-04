//
//  FeedDetailViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/18/24.
//

import Combine
import SafariServices
import UIKit

import SnapKit

@frozen
enum FeedDetailSection: Int, CaseIterable {
    case feed
    case reply
}

final class FeedDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: FeedDetailViewModel
    private let likeViewModel: LikeViewModel
    private var cancelBag = CancelBag()
    
    private lazy var postButtonTapped =
    self.feedDetailView.bottomWriteView.uploadButton.publisher(for: .touchUpInside).map { _ in
        return (WriteReplyRequestDTO(
            commentText: self.feedDetailView.bottomWriteView.writeTextView.text,
            notificationTriggerType: "comment"), self.contentId)
    }.eraseToAnyPublisher()
    
    private lazy var deleteButtonTapped = deletePopupView?.confirmButton.publisher(for: .touchUpInside).map { _ in
        return self.contentId
    }.eraseToAnyPublisher()
    
    var contentId: Int = 0
    var commentId: Int = 0
    var memberId: Int = 0
    var postMemberId: Int = 0
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    var ghostReason: String = ""
    var postViewHeight = 0
    var userNickName: String = ""
    var contentText: String = ""
    var reportTargetNickname: String = ""
    var relateText: String = ""
    let warnUserURL = URL(string: StringLiterals.Network.warnUserGoogleFormURL)
    private let placeholder = StringLiterals.Home.placeholder
    
    var nowShowingPopup: String = ""
    
    let refreshControl = UIRefreshControl()
    
    var feedData: HomeFeedDTO? = nil
    
    // MARK: - UI Components
    
    private let feedDetailView = FeedDetailView()
    
    var homeBottomsheetView = HomeBottomSheetView()
    private var ghostPopupView: WablePopupView? = nil
    private var reportPopupView: WablePopupView? = nil
    private var deletePopupView: WablePopupView? = nil
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        view = feedDetailView
        self.view.backgroundColor = .wableWhite
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        setNavigationBar()
        dismissKeyboard()
        setRefreshControl()
    }
    
    init(viewModel: FeedDetailViewModel, likeViewModel: LikeViewModel) {
        self.viewModel = viewModel
        self.likeViewModel = likeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "게시글"
        
        getAPI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Extensions

extension FeedDetailViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        feedDetailView.feedDetailTableView.rowHeight = UITableView.automaticDimension
        feedDetailView.feedDetailTableView.estimatedRowHeight = 100
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {
        feedDetailView.feedDetailTableView.delegate = self
        feedDetailView.feedDetailTableView.dataSource = self
        feedDetailView.bottomWriteView.writeTextView.delegate = self
    }
    
    private func setNavigationBar() {
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
    private func setRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        feedDetailView.feedDetailTableView.refreshControl = self.refreshControl
    }
    
    @objc
    private func didPullToRefresh() {
        print("didPullToRefresh")
        DispatchQueue.main.async {
            self.getAPI()
        }
        self.perform(#selector(finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    private func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    
    func getFeedData(data: HomeFeedDTO) {
        self.feedData = data
    }
    
    @objc
    private func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    
    
}

// MARK: - Network

extension FeedDetailViewController {
    private func getAPI() {
        let input = FeedDetailViewModel.Input(viewUpdate: Just((contentId)).eraseToAnyPublisher(),
                                              likeButtonTapped: nil,
                                              tableViewUpdata: Just((contentId)).eraseToAnyPublisher(),
                                              commentLikeButtonTapped: nil,
                                              postButtonTapped: postButtonTapped)
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.getPostData
            .receive(on: RunLoop.main)
            .sink { data in
                self.postMemberId = data.memberId
                self.feedDetailView.feedDetailTableView.reloadData()
            }
            .store(in: self.cancelBag)
        
        output.getPostReplyData
            .receive(on: RunLoop.main)
            .sink { data in
                self.feedDetailView.feedDetailTableView.reloadData()
            }
            .store(in: self.cancelBag)
        
        output.postReplyCompleted
            .receive(on: RunLoop.main)
            .sink { data in
                if data == 0 {
                    self.viewModel.cursor = -1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.didPullToRefresh()
                        
                        self.feedDetailView.bottomWriteView.writeTextView.text = ""
                        self.feedDetailView.bottomWriteView.writeTextView.textColor = .gray700
                        self.feedDetailView.bottomWriteView.writeTextView.text = (self.feedData?.memberNickname ?? "") + self.placeholder
                        self.feedDetailView.bottomWriteView.writeTextView.textContainerInset = UIEdgeInsets(top: 10.adjusted,
                                                                                                            left: 10.adjusted,
                                                                                                            bottom: 10.adjusted,
                                                                                                            right: 10.adjusted)
                        
                        UIView.animate(withDuration: 0.3) {
                            self.feedDetailView.feedDetailTableView.contentOffset.y = 0
                        }
                    }
                }
            }
            .store(in: cancelBag)
    }
    
    @objc
    func finishedRefreshing() {
        refreshControl.endRefreshing()
    }
}

// MARK: - TextView Delegate

extension FeedDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .gray700 else { return }
        textView.textColor = .wableBlack
        textView.text = nil
        print("textViewDidBeginEditing")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height > 86 {
            textView.isScrollEnabled = true
            return
        } else {
            //                textView.isScrollEnabled = false
            textView.isScrollEnabled = true
            
            // 레이아웃 중 height 수정
            textView.snp.remakeConstraints {
                $0.height.equalTo(estimatedSize)
                $0.leading.equalToSuperview().inset(16.adjusted)
                $0.trailing.equalTo(feedDetailView.bottomWriteView.uploadButton.snp.leading).offset(-6.adjusted)
                $0.centerY.equalToSuperview()
            }
            
            feedDetailView.bottomWriteView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                $0.height.equalTo(estimatedSize.height + 20)
            }
        }
        
        if (textView.text.count != 0) {
            feedDetailView.bottomWriteView.uploadButton.isEnabled = true
        } else {
            feedDetailView.bottomWriteView.uploadButton.isEnabled = false
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        
        if textView.text.isEmpty {
            textView.text = (feedData?.memberNickname ?? String()) + StringLiterals.Home.placeholder
            textView.textColor = .gray700
            feedDetailView.bottomWriteView.uploadButton.isEnabled = false
        }
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

// MARK: - TableView Delegate, DataSource

extension FeedDetailViewController: UITableViewDelegate {}

extension FeedDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = FeedDetailSection(rawValue: section) else { return 0 }
        switch sectionType {
        case .feed:
            return 1
        case .reply:
            return viewModel.feedReplyDatas.count
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == feedDetailView.feedDetailTableView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height) {
                let lastCommentID = viewModel.feedReplyDatas.last?.commentId ?? -1
                viewModel.cursor = lastCommentID
//                self.didPullToRefresh()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = FeedDetailSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch sectionType {
        case .feed:
            let cell = feedDetailView.feedDetailTableView.dequeueReusableCell(withIdentifier: HomeFeedTableViewCell.identifier, for: indexPath) as? HomeFeedTableViewCell ?? HomeFeedTableViewCell()
            cell.selectionStyle = .none
            cell.seperateLineView.isHidden = false
            print("feedData: \(feedData)")
            cell.bind(data: feedData ?? HomeFeedDTO(memberID: 0,
                                                    memberProfileURL: "",
                                                    memberNickname: "다시하세요",
                                                    contentID: 0, contentTitle: "contentTitle",
                                                    contentText: "",
                                                    time: "다시해",
                                                    isGhost: false,
                                                    memberGhost: 0,
                                                    isLiked: true,
                                                    likedNumber: 5,
                                                    commentNumber: 2,
                                                    isDeleted: false,
                                                    contentImageURL: "",
                                                    memberFanTeam: "T1"))
            
            if feedData?.memberID == loadUserData()?.memberId {
                cell.bottomView.ghostButton.isHidden = true
                
                cell.menuButtonTapped = {
                    self.homeBottomsheetView.showSettings()
                    self.homeBottomsheetView.deleteButton.isHidden = false
                    self.homeBottomsheetView.reportButton.isHidden = true
                    
                    self.homeBottomsheetView.deleteButton.addTarget(self, action: #selector(self.deletePostButtonTapped), for: .touchUpInside)
                    self.contentId = self.feedData?.contentID ?? 0
                    self.nowShowingPopup = "delete"
                }
            } else {
                // 다른 유저인 경우
                cell.bottomView.ghostButton.isHidden = false
                
                cell.menuButtonTapped = {
                    self.homeBottomsheetView.showSettings()
                    self.homeBottomsheetView.reportButton.isHidden = false
                    self.homeBottomsheetView.deleteButton.isHidden = true
                    
                    self.reportTargetNickname = self.feedData?.memberNickname ?? ""
                    self.relateText = self.feedData?.contentText ?? ""
                    self.homeBottomsheetView.reportButton.addTarget(self, action: #selector(self.reportButtonTapped), for: .touchUpInside)
                    self.nowShowingPopup = "report"
                }
            }
            
            var memberGhost = feedData?.memberGhost
            memberGhost = adjustGhostValue(memberGhost ?? 0)
            
            cell.grayView.layer.zPosition = 1
            
            // 내가 투명도를 누른 유저인 경우 -85% 적용
            if feedData?.isGhost == true {
                cell.grayView.alpha = 0.85
            } else {
                cell.grayView.alpha = CGFloat(Double(-(memberGhost ?? 0)) / 100)
            }
            
            cell.profileButtonAction = {
                let memberId = self.feedData?.memberID

                if memberId == loadUserData()?.memberId ?? 0  {
                    self.tabBarController?.selectedIndex = 3
                } else {
                    let viewController = MyPageViewController(viewModel: MyPageViewModel(networkProvider: NetworkService()))
                    viewController.memberId = memberId ?? 0
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
                self.postLikeButtonAPI(isClicked: cell.bottomView.isLiked, contentId: self.feedData?.contentID ?? 0)
                
                cell.bottomView.isLiked.toggle()
            }
            
            return cell
        case .reply:
            let cell = feedDetailView.feedDetailTableView.dequeueReusableCell(withIdentifier: FeedDetailTableViewCell.identifier, for: indexPath) as? FeedDetailTableViewCell ?? FeedDetailTableViewCell()
            cell.selectionStyle = .none
            cell.bind(data: viewModel.feedReplyDatas[indexPath.row])
            return cell
        }
    }
}

// MARK: - Network

extension FeedDetailViewController {
    private func postLikeButtonAPI(isClicked: Bool, contentId: Int) {
        // 최초 한 번만 publisher 생성
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?  = Just(())
                .map { _ in return (isClicked, contentId) }
                .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
                .eraseToAnyPublisher()
        
        let input = LikeViewModel.Input(likeButtonTapped: likeButtonTapped, deleteButtonDidTapped: deleteButtonTapped)

        let output = self.likeViewModel.transform(from: input, cancelBag: self.cancelBag)

        output.toggleLikeButton
            .sink { _ in }
            .store(in: self.cancelBag)
    }
}


extension FeedDetailViewController: WablePopupDelegate {
    
    func cancleButtonTapped() {
//        if nowShowingPopup == "ghost" {
//            self.ghostPopupView?.removeFromSuperview()
//        }
        
        if nowShowingPopup == "report" {
            self.reportPopupView?.removeFromSuperview()
        }
        
        if nowShowingPopup == "delete" {
            self.deletePopupView?.removeFromSuperview()
        }
    }
    
    func confirmButtonTapped() {
//        if nowShowingPopup == "ghost" {
//            self.ghostPopupView?.removeFromSuperview()
//            
//            Task {
//                do {
//                    if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
//                        let result = try await self.likeViewModel.postDownTransparency(
//                            accessToken: accessToken,
//                            alarmTriggerType: self.alarmTriggerType,
//                            targetMemberId: self.targetMemberId,
//                            alarmTriggerId: self.alarmTriggerdId,
//                            ghostReason: self.ghostReason
//                        )
//                        
//                        didPullToRefresh()
//                        
//                        if result?.status == 400 {
//                            // 이미 투명도를 누른 대상인 경우, 토스트 메시지 보여주기
////                            showAlreadyTransparencyToast()
//                            print("이미 투명도를 누른 대상인 경우, 토스트 메시지 보여주기")
//                        }
//                    }
//                } catch {
//                    print(error)
//                }
//            }
//        }
        
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
                        
                        navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
