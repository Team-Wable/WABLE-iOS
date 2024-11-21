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
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var postButtonTapped =
    self.feedDetailView.bottomWriteView.uploadButton.publisher(for: .touchUpInside)
        .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
        .map { _ in
            
            self.feedDetailView.bottomWriteView.writeTextView.resignFirstResponder()
            
            return (WriteReplyRequestDTO(
                commentText: self.feedDetailView.bottomWriteView.writeTextView.text,
                notificationTriggerType: "comment"), self.contentId, self.feedData?.memberNickname ?? "")
            
        }.eraseToAnyPublisher()
    
    private lazy var deleteButtonTapped = deletePopupView?.confirmButton.publisher(for: .touchUpInside).map { _ in
        return self.contentId
    }.eraseToAnyPublisher()
    
    private lazy var deleteReplyButtonTapped = deletePopupView?.confirmButton.publisher(for: .touchUpInside).map { _ in
        return self.commentId
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
    var getFeedData: FeedDetailResponseDTO? = nil
    
    private var paginationReplyData: [FlattenReplyModel] = []
    private var replyData: [FlattenReplyModel] = [] {
        didSet {
            self.feedDetailView.feedDetailTableView.reloadData()
        }
    }
    
    // TODO: - 이놈의 아웃풋 = textField placeholder??(닉네임)
    private let replyButtonDidTapSubject = PassthroughSubject<Int?, Never>()
    
    // MARK: - UI Components
    
    private let feedDetailView = FeedDetailView()
    
    var homeBottomsheetView = HomeBottomSheetView()
    private var ghostPopupView: WablePopupView? = nil
    private var reportPopupView: WablePopupView? = nil
    private var deletePopupView: WablePopupView? = nil
    private var photoDetailView: WablePhotoDetailView?
    
    private var reportToastView: UIImageView?
    private var ghostToastView: UIImageView?
    
    private let topDivisionLine = UIView().makeDivisionLine()
    
    // MARK: - Life Cycles
    
    override func loadView() {

        view = feedDetailView
        self.view.backgroundColor = .wableWhite
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        bindViewModel()
        getAPI()
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
        
        setNavigationBar()
        viewModel.viewWillAppear.send(contentId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - Extensions

extension FeedDetailViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        feedDetailView.feedDetailTableView.rowHeight = UITableView.automaticDimension
        feedDetailView.feedDetailTableView.estimatedRowHeight = 100
        feedDetailView.bottomWriteView.setPlaceholder(nickname: self.feedData?.memberNickname ?? "")
        feedDetailView.bottomWriteView.writeTextView.textContainerInset = UIEdgeInsets(top: 10.adjusted,
                                                                                       left: 10.adjusted,
                                                                                       bottom: 10.adjusted,
                                                                                       right: 10.adjusted)
        
        navigationController?.navigationBar.barTintColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.view.addSubview(topDivisionLine)
    }
    
    private func setLayout() {
        topDivisionLine.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
        }
    }
    
    private func setDelegate() {
        feedDetailView.feedDetailTableView.delegate = self
        feedDetailView.feedDetailTableView.dataSource = self
        feedDetailView.bottomWriteView.writeTextView.delegate = self
    }
    
    private func setNavigationBar() {
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.barTintColor = .wableWhite
        self.navigationItem.title = "게시글"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        
        navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
    private func bindViewModel() {
        viewModel.replyDatas
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.replyData = data
                self?.feedDetailView.feedDetailTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.replyPaginationDatas
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.replyData.append(contentsOf: data)
            }
            .store(in: &cancellables)
        
    }
    
    private func setRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        feedDetailView.feedDetailTableView.refreshControl = self.refreshControl
    }
    
    @objc
    private func didPullToRefresh() {
        print("didPullToRefresh")
        self.viewModel.cursor = -1
        DispatchQueue.main.async {
            self.getAPI()
            self.viewModel.viewWillAppear.send(self.contentId)
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
}

// MARK: - Network

extension FeedDetailViewController {
    private func getAPI() {
        print("getAPI")
        let input = FeedDetailViewModel.Input(viewUpdate: Just((contentId)).eraseToAnyPublisher(),
                                              likeButtonTapped: nil,
                                              commentLikeButtonTapped: nil,
                                              postButtonTapped: postButtonTapped)
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.getPostData
            .receive(on: RunLoop.main)
            .sink { data in
                self.postMemberId = data.memberId
                self.getFeedData = data
            }
            .store(in: self.cancelBag)
        
        output.postReplyCompleted
            .receive(on: RunLoop.main)
            .sink { data in
                if data == 0 {
                    self.viewModel.cursor = -1
                    self.replyData = []
                    self.paginationReplyData = []
                    DispatchQueue.main.async {
                        self.didPullToRefresh()
                        self.feedDetailView.bottomWriteView.uploadButton.isEnabled = false
                        self.feedDetailView.bottomWriteView.writeTextView.text = nil
                        self.feedDetailView.bottomWriteView.setPlaceholder(nickname: self.feedData?.memberNickname ?? "")
                        self.feedDetailView.bottomWriteView.writeTextView.textContainerInset = UIEdgeInsets(top: 10.adjusted,
                                                                                                            left: 10.adjusted,
                                                                                                            bottom: 10.adjusted,
                                                                                                            right: 10.adjusted)
                        
                        self.feedDetailView.bottomWriteView.uploadButton.setImage(ImageLiterals.Button.btnRippleDefault, for: .normal)
                    }
                }
            }
            .store(in: cancelBag)
        
        viewModel.isButtonEnabled
            .receive(on: RunLoop.main)
            .sink { isEnabled in
                print("🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣upload Button isEnabled = \(isEnabled)🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣")
                self.feedDetailView.bottomWriteView.uploadButton.isEnabled = isEnabled
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 전체 텍스트 삭제를 확인
        let isDeletingAllText = range == NSRange(location: 0, length: textView.text.count) && text.isEmpty
        
        if isDeletingAllText {
            setTextViewHeight(textView, isDeletingAllText: isDeletingAllText)
        }
    
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        // 텍스트뷰 크기 조정 로직
        setTextViewHeight(textView, isDeletingAllText: false)
        
        guard !textView.text.isEmpty else {
            // TODO: - 여기 닉네임 받는 부분 변경. vc 프로퍼티 아니도록
            feedDetailView.bottomWriteView.setPlaceholder(nickname: feedData?.memberNickname ?? String())
            return
        }
        
        feedDetailView.bottomWriteView.placeholderLabel.isHidden = true
        
        if !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            makeUploadButtonActivate()
        } else {
            makeUploadButtonDeactivate()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        
        if textView.text.isEmpty {
            feedDetailView.bottomWriteView.setPlaceholder(nickname: feedData?.memberNickname ?? String())
            makeUploadButtonDeactivate()
        }
    }
    
    // 댓글 작성 중 텍스트뷰 높이 조정
    func setTextViewHeight(_ textView: UITextView, isDeletingAllText: Bool) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.isScrollEnabled = !isDeletingAllText && estimatedSize.height >= 95.adjusted
        
        feedDetailView.bottomWriteView.writeTextView.snp.updateConstraints {
            $0.height.lessThanOrEqualTo(100.adjusted)
        }
        
        feedDetailView.bottomWriteView.snp.updateConstraints {
            $0.height.lessThanOrEqualTo(120.adjusted)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 댓글 업로드 버튼 활성화
    private func makeUploadButtonActivate() {
        feedDetailView.bottomWriteView.uploadButton.setImage(ImageLiterals.Button.btnRipplePress, for: .normal)
        feedDetailView.bottomWriteView.uploadButton.isEnabled = true
    }
    
    // 댓글 업로드 버튼 비활성화
    private func makeUploadButtonDeactivate() {
        feedDetailView.bottomWriteView.uploadButton.setImage(ImageLiterals.Button.btnRippleDefault, for: .normal)
        feedDetailView.bottomWriteView.uploadButton.isEnabled = false
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
            print("viewModel.feedReplyDatas.count: \(self.replyData.count)")
            return self.replyData.count
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == feedDetailView.feedDetailTableView {
            let lastCommentID = self.replyData.last?.commentID ?? Int()

            if replyData.count % 15 == 0 && viewModel.cursor != lastCommentID && (scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height) {
                viewModel.cursor = lastCommentID
                viewModel.paginationDidAction.send(contentId)
                print("===================Pagination 작동===================")
                DispatchQueue.main.async {
                    self.feedDetailView.feedDetailTableView.reloadData()
                }
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
            
            cell.alarmTriggerType = "contentGhost"
            cell.targetMemberId = feedData?.memberID ?? 0
            cell.alarmTriggerdId = feedData?.contentID ?? 0
            
            if let feedData = feedData {
                cell.bind(data: feedData)
            } else {
                cell.bind(data: HomeFeedDTO(
                    memberID: getFeedData?.memberId ?? 0,
                    memberProfileURL: getFeedData?.memberProfileUrl ?? "",
                    memberNickname: getFeedData?.memberNickname ?? "",
                    isGhost: getFeedData?.isGhost ?? false,
                    memberGhost: getFeedData?.memberGhost ?? 0,
                    isLiked: getFeedData?.isLiked ?? false,
                    time: getFeedData?.time ?? "",
                    likedNumber: getFeedData?.likedNumber ?? 0,
                    memberFanTeam: getFeedData?.memberFanTeam ?? "",
                    contentID: self.contentId,
                    contentTitle: getFeedData?.contentTitle ?? "",
                    contentText: getFeedData?.contentText ?? "",
                    commentNumber: getFeedData?.commentNumber ?? 0,
                    isDeleted: false,
                    message: getFeedData?.contentImageUrl ?? "",
                    commnetNumber: 0,
                    contentImageURL: "")
                )
            }
            
            if feedData?.memberID == loadUserData()?.memberId || getFeedData?.memberId == loadUserData()?.memberId {
                cell.bottomView.ghostButton.isHidden = true
                
                cell.menuButtonTapped = {
                    self.homeBottomsheetView.showSettings()
                    self.homeBottomsheetView.deleteButton.isHidden = false
                    self.homeBottomsheetView.reportButton.isHidden = true
                    
                    self.homeBottomsheetView.deleteButton.addTarget(self, action: #selector(self.deletePostButtonTapped), for: .touchUpInside)
                    if let feedData = self.feedData {
                        self.contentId = feedData.contentID ?? 0
                    }
                    self.nowShowingPopup = "deletePost"
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
                if let feedData = self.feedData {
                    if feedData.memberID == loadUserData()?.memberId ?? 0  {
                        self.tabBarController?.selectedIndex = 3
                    } else {
                        let viewController = MyPageViewController(viewModel: MyPageViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
                        viewController.memberId = feedData.memberID
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            }
            
            cell.bottomView.ghostButtonTapped = { [weak self] in
                AmplitudeManager.shared.trackEvent(tag: "click_ghost_post")
                self?.alarmTriggerType = cell.alarmTriggerType
                self?.targetMemberId = cell.targetMemberId
                self?.alarmTriggerdId = cell.alarmTriggerdId
                self?.showGhostPopupView()
                self?.nowShowingPopup = "ghost"
            }
            
            cell.bottomView.heartButtonTapped = {
                var currentHeartCount = cell.bottomView.heartButton.titleLabel?.text
                
                if cell.bottomView.isLiked == true {
                    cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) - 1)", font: .caption1, textColor: .gray600)
                } else {
                    AmplitudeManager.shared.trackEvent(tag: "click_like_post")
                    cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) + 1)", font: .caption1, textColor: .gray600)
                }
                if let feedData = self.feedData {
                    self.postLikeButtonAPI(isClicked: cell.bottomView.isLiked, contentId: feedData.contentID ?? 0)
                } else {
                    self.postLikeButtonAPI(isClicked: cell.bottomView.isLiked, contentId: self.contentId)
                }
                
                cell.bottomView.isLiked.toggle()
            }
            
            cell.divideLine.isHidden = true
            
            cell.contentImageViewTapped = { [weak self] in
                DispatchQueue.main.async {
                    self?.photoDetailView = WablePhotoDetailView()
                    
                    if let window = UIApplication.shared.keyWindowInConnectedScenes {
                        window.addSubview(self?.photoDetailView ?? WablePhotoDetailView())
                        
                        self?.photoDetailView?.removePhotoButton.addTarget(self, action: #selector(self?.removePhotoButtonTapped), for: .touchUpInside)
                        
                        if let imageURL = self?.feedData?.contentImageURL {
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
            
            // 게시글에 대한 댓글 달기 버튼이 눌렸을 때는 nil로 보내기
            // 기존에 있었던 댓글 삭제해야함
            cell.bottomView.commentButtonTapped = { [weak self] in
                self?.feedDetailView.bottomWriteView.writeTextView.becomeFirstResponder()
                self?.replyButtonDidTapSubject.send(nil)
                
            }
            
            return cell
            
        case .reply:
            let cell = feedDetailView.feedDetailTableView.dequeueReusableCell(withIdentifier: FeedDetailTableViewCell.identifier, for: indexPath) as? FeedDetailTableViewCell ?? FeedDetailTableViewCell()
            cell.selectionStyle = .none
            cell.alarmTriggerType = "commentGhost"
            cell.targetMemberId = self.replyData[indexPath.row].memberID
            cell.alarmTriggerdId = self.replyData[indexPath.row].commentID
            
            cell.bind(data: self.replyData[indexPath.row])
            
            if self.replyData[indexPath.row].memberID == loadUserData()?.memberId {
                cell.bottomView.ghostButton.isHidden = true
                
                cell.menuButtonTapped = {
                    self.homeBottomsheetView.showSettings()
                    self.homeBottomsheetView.deleteButton.isHidden = false
                    self.homeBottomsheetView.reportButton.isHidden = true
                    
                    self.homeBottomsheetView.deleteButton.addTarget(self, action: #selector(self.deletePostButtonTapped), for: .touchUpInside)
                    self.commentId = self.replyData[indexPath.row].commentID
                    self.nowShowingPopup = "deleteReply"
                }
            } else {
                // 다른 유저인 경우
                cell.bottomView.ghostButton.isHidden = false
                
                cell.menuButtonTapped = {
                    self.homeBottomsheetView.showSettings()
                    self.homeBottomsheetView.reportButton.isHidden = false
                    self.homeBottomsheetView.deleteButton.isHidden = true
                    
                    self.reportTargetNickname = self.replyData[indexPath.row].memberNickname
                    self.relateText = self.replyData[indexPath.row].commentText
                    self.homeBottomsheetView.reportButton.addTarget(self, action: #selector(self.reportButtonTapped), for: .touchUpInside)
                    self.nowShowingPopup = "report"
                }
            }
            
            var memberGhost = self.replyData[indexPath.row].memberGhost
            memberGhost = adjustGhostValue(memberGhost)
            
            cell.grayView.layer.zPosition = 1
            
            // 내가 투명도를 누른 유저인 경우 -85% 적용
            if self.replyData[indexPath.row].isGhost {
                cell.grayView.alpha = 0.85
            } else {
                cell.grayView.alpha = CGFloat(Double(-memberGhost) / 100)
            }
            
            cell.profileButtonAction = {
                let memberId = self.replyData[indexPath.row].memberID

                if memberId == loadUserData()?.memberId ?? 0  {
                    self.tabBarController?.selectedIndex = 3
                } else {
                    let viewController = MyPageViewController(viewModel: MyPageViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
                    viewController.memberId = memberId
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            
            cell.bottomView.ghostButtonTapped = { [weak self] in
                AmplitudeManager.shared.trackEvent(tag: "click_ghost_comment")
                self?.alarmTriggerType = cell.alarmTriggerType
                self?.targetMemberId = cell.targetMemberId
                self?.alarmTriggerdId = cell.alarmTriggerdId
                self?.showGhostPopupView()
                self?.nowShowingPopup = "ghost"
            }
            
            cell.bottomView.heartButtonTapped = {
                var currentHeartCount = cell.bottomView.heartButton.titleLabel?.text
                
                if cell.bottomView.isLiked == true {
                    cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) - 1)", font: .caption1, textColor: .gray600)
                } else {
                    AmplitudeManager.shared.trackEvent(tag: "click_like_comment")
                    cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) + 1)", font: .caption1, textColor: .gray600)
                }
                self.postCommentLikeButtonAPI(isClicked: cell.bottomView.isLiked, commentId: self.replyData[indexPath.row].commentID, commentText: self.replyData[indexPath.row].commentText)
                
                cell.bottomView.isLiked.toggle()
            }
            
            cell.bottomView.replyButtonTapped = { [weak self] in
                self?.feedDetailView.bottomWriteView.writeTextView.resignFirstResponder()
                
                // MARK: - 여기서 인덱스로 유저 닉네임, 댓글작성자 ID, 댓글ID 찾아서 다시 VC로 전달
                self?.replyButtonDidTapSubject.send(indexPath.row)
                
                self?.feedDetailView.bottomWriteView.writeTextView.becomeFirstResponder()

            }
            
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
        
        let input = LikeViewModel.Input(likeButtonTapped: likeButtonTapped, commentLikeButtonTapped: nil, deleteButtonDidTapped: deleteButtonTapped, deleteReplyButtonDidTapped: deleteReplyButtonTapped)

        let output = self.likeViewModel.transform(from: input, cancelBag: self.cancelBag)

        output.toggleLikeButton
            .sink { _ in }
            .store(in: self.cancelBag)
    }
    
    private func postCommentLikeButtonAPI(isClicked: Bool, commentId: Int, commentText: String) {
        print("postCommentLikeButtonAPI")
        // 최초 한 번만 publisher 생성
        let commentLikedButtonTapped: AnyPublisher<(Bool, Int, String), Never>? = Just(())
            .map { _ in return (isClicked, commentId, commentText) }
            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
            .eraseToAnyPublisher()
        
        let input = LikeViewModel.Input(likeButtonTapped: nil, commentLikeButtonTapped: commentLikedButtonTapped, deleteButtonDidTapped: deleteButtonTapped, deleteReplyButtonDidTapped: deleteReplyButtonTapped)
        let output = self.likeViewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.toggleCommentLikeButton
            .sink { _ in }
            .store(in: self.cancelBag)
    }
}


extension FeedDetailViewController: WablePopupDelegate {
    
    func cancleButtonTapped() {
        if nowShowingPopup == "ghost" {
            AmplitudeManager.shared.trackEvent(tag: "click_withdrawghost_popup")
            self.ghostPopupView?.removeFromSuperview()
        }
        
        if nowShowingPopup == "report" {
            self.reportPopupView?.removeFromSuperview()
        }
        
        if nowShowingPopup == "deletePost" || nowShowingPopup == "deleteReply" {
            self.deletePopupView?.removeFromSuperview()
        }
    }
    
    // MARK: - 투명도 버튼 눌렸을 때 실행되는 코드
    
    func confirmButtonTapped() {
        if nowShowingPopup == "ghost" {
            self.ghostPopupView?.removeFromSuperview()
            AmplitudeManager.shared.trackEvent(tag: "click_applyghost_popup")
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
                        
                        self.ghostToastView = UIImageView(image: ImageLiterals.Toast.toastGhost)
                        self.ghostToastView?.contentMode = .scaleAspectFit
                        
                        if let ghostToastView = self.ghostToastView {
                            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                                window.addSubviews(ghostToastView)
                            }
                            
                            ghostToastView.snp.makeConstraints {
                                $0.top.equalToSuperview().inset(75.adjusted)
                                $0.centerX.equalToSuperview()
                                $0.width.equalTo(343.adjusted)
                            }
                            
                            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn) {
                                self.ghostToastView?.alpha = 0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.ghostToastView?.removeFromSuperview()
                            }
                        }
                        
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
        
        if nowShowingPopup == "deletePost" {
            self.deletePopupView?.removeFromSuperview()
            AmplitudeManager.shared.trackEvent(tag: "click_delete_post")
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
        
        if nowShowingPopup == "deleteReply" {
            self.deletePopupView?.removeFromSuperview()
            
            Task {
                do {
                    if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                        let result = try await self.likeViewModel.deleteReplyAPI(accessToken: accessToken, commentId: self.commentId)
                        
                        didPullToRefresh()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func singleButtonTapped() {
        
    }
}

