//
//  MyPageReplyViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/19/24.
//

import Combine
import UIKit

import SnapKit

final class MyPageReplyViewController: UIViewController {
    
    // MARK: - Properties
    
    let feedReplyDummy: [FeedDetailReplyDTO] = [FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "하암",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 11,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "T1"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "뭘봐",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 21,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "DRX"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "하암",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 11,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말시발발발발발발바랍라발바라왜안되는데",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "T1"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "뭘봐",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 21,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "DRX"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "하암",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 11,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "T1"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "뭘봐",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 21,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "DRX")]
    
    var feedData: HomeFeedDTO? = nil
    
    static let pushViewController = NSNotification.Name("pushViewController")
    static let reloadData = NSNotification.Name("reloadData")
    static let warnUserButtonTapped = NSNotification.Name("warnUserButtonTapped")
    static let ghostButtonTapped = NSNotification.Name("ghostButtonCommentTapped")
    static let reloadCommentData = NSNotification.Name("reloadCommentData")
    
    var showUploadToastView: Bool = false
    private let refreshControl = UIRefreshControl()
    
//    private let postViewModel: PostDetailViewModel
    private let myPageViewModel: MyPageViewModel
//    let deleteViewModel = DeleteReplyViewModel(networkProvider: NetworkService())
    private var cancelBag = CancelBag()
    
//    var profileData: [MypageProfileResponseDTO] = []
//    var commentDatas: [MyPageMemberCommentResponseDTO] = []
    
    // var commentData = MyPageViewModel(networkProvider: NetworkService()).myPageCommentData
    var contentId: Int = 0
    var commentId: Int = 0
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    
    // MARK: - UI Components
    
    lazy var feedDetailTableView = FeedDetailView().feedDetailTableView
    let noCommentLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 작성한 댓글이 없어요."
        label.textColor = .gray500
        label.font = .body2
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Life Cycles
    
    init(myPageViewModel: MyPageViewModel) {
//        self.postViewModel = viewModel
        self.myPageViewModel = myPageViewModel
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
        setRefreshControll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        refreshPostDidDrag()
        setNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        NotificationCenter.default.removeObserver(self, name: MyPageCommentViewController.reloadData, object: nil)
    }
}

// MARK: - Extensions

extension MyPageReplyViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = true
        
//        deleteReplyPopupVC.modalPresentationStyle = .overFullScreen
    }
    
    private func setHierarchy() {
        view.addSubviews(feedDetailTableView, noCommentLabel)
    }
    
    private func setLayout() {
        feedDetailTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        noCommentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(44.adjusted)
            $0.leading.trailing.equalToSuperview().inset(20.adjusted)
        }
    }
    
    private func setDelegate() {
        feedDetailTableView.dataSource = self
        feedDetailTableView.delegate = self
    }
    
    private func setRefreshControll() {
        refreshControl.addTarget(self, action: #selector(refreshPostDidDrag), for: .valueChanged)
        feedDetailTableView.refreshControl = refreshControl
        refreshControl.backgroundColor = .wableWhite
    }
    
    private func setNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: MyPageCommentViewController.reloadData, object: nil)
    }
    
    @objc
    func refreshPostDidDrag() {
//        DispatchQueue.main.async {
//            self.homeCollectionView.reloadData()
//        }
//        self.perform(#selector(self.finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    func reloadData(_ notification: Notification) {
        refreshPostDidDrag()
    }
    
    @objc
    func finishedRefreshing() {
        refreshControl.endRefreshing()
    }
    
    @objc
    private func deleteButtonTapped() {
        popDeleteView()
        deleteReplyPopupView()
    }
    
    @objc
    private func warnButtonTapped() {
//        popWarnView()
//        NotificationCenter.default.post(name: MyPageContentViewController.warnUserButtonTapped, object: nil)
    }
    
    func popDeleteView() {
//        if UIApplication.shared.keyWindowInConnectedScenes != nil {
//            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.deleteBottomsheet.dimView.alpha = 0
//                if let window = UIApplication.shared.keyWindowInConnectedScenes {
//                    self.deleteBottomsheet.bottomsheetView.frame = CGRect(x: 0, y: window.frame.height, width: self.deleteBottomsheet.frame.width, height: self.deleteBottomsheet.bottomsheetView.frame.height)
//                }
//            })
//            deleteBottomsheet.dimView.removeFromSuperview()
//            deleteBottomsheet.bottomsheetView.removeFromSuperview()
//        }
//        refreshPostDidDrag()
    }
    
    func popWarnView() {
//        if UIApplication.shared.keyWindowInConnectedScenes != nil {
//            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.warnBottomsheet.dimView.alpha = 0
//                if let window = UIApplication.shared.keyWindowInConnectedScenes {
//                    self.warnBottomsheet.bottomsheetView.frame = CGRect(x: 0, y: window.frame.height, width: self.deleteBottomsheet.frame.width, height: self.warnBottomsheet.bottomsheetView.frame.height)
//                }
//            })
//            warnBottomsheet.dimView.removeFromSuperview()
//            warnBottomsheet.bottomsheetView.removeFromSuperview()
//        }
//        refreshPostDidDrag()
    }
    
    func presentView() {
//        deleteReplyPopupVC.commentId = self.commentId
//        self.present(self.deleteReplyPopupVC, animated: false, completion: nil)
    }
    
    private func postCommentLikeButtonAPI(isClicked: Bool, commentId: Int, commentText: String) {
//        // 최초 한 번만 publisher 생성
//        let commentLikedButtonTapped: AnyPublisher<(Bool, Int, String), Never>? = Just(())
//            .map { _ in return (!isClicked, commentId, commentText) }
//            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
//            .eraseToAnyPublisher()
//        
//        let input = PostDetailViewModel.Input(viewUpdate: nil,
//                                              likeButtonTapped: nil,
//                                              collectionViewUpdata: nil,
//                                              commentLikeButtonTapped: commentLikedButtonTapped,
//                                              firstReasonButtonTapped: nil,
//                                              secondReasonButtonTapped: nil,
//                                              thirdReasonButtonTapped: nil,
//                                              fourthReasonButtonTapped: nil,
//                                              fifthReasonButtonTapped: nil,
//                                              sixthReasonButtonTapped: nil)
//        
//        let output = self.postViewModel.transform(from: input, cancelBag: self.cancelBag)
//        
//        output.toggleLikeButton
//            .sink { _ in }
//            .store(in: self.cancelBag)
    }
    
    func deleteReplyPopupView() {
//        deleteReplyPopupVC.commentId = self.commentId
//        self.present(self.deleteReplyPopupVC, animated: false, completion: nil)
    }
}

extension MyPageReplyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedReplyDummy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedDetailTableView.dequeueReusableCell(withIdentifier: FeedDetailTableViewCell.identifier, for: indexPath) as? FeedDetailTableViewCell ?? FeedDetailTableViewCell()
        cell.selectionStyle = .none
        cell.bind(data: feedReplyDummy[indexPath.row])
        
//        cell.bottomView.commentButtonTapped = { [weak self] in
//            self?.viewModel.commentButtonTapped.send(indexPath.row)
//        }
        
        cell.bottomView.ghostButtonTapped = { [weak self] in
            print("ghostButtonTapped")
//            self.alarmTriggerType = cell.alarmTriggerType
//            self.targetMemberId = cell.targetMemberId
//            self.alarmTriggerdId = cell.alarmTriggerdId
            NotificationCenter.default.post(name: MyPageReplyViewController.ghostButtonTapped, object: nil)
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
//        let contentId = commentDatas[indexPath.row].contentId
//        let profileImageURL = commentDatas[indexPath.row].memberProfileUrl
//        NotificationCenter.default.post(name: MyPageContentViewController.pushViewController, object: nil, userInfo: ["contentId": contentId, "profileImageURL": profileImageURL])
        NotificationCenter.default.post(name: MyPageReplyViewController.pushViewController, object: nil)
    }
}

extension MyPageReplyViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if yOffset > 0 {
            scrollView.isScrollEnabled = true
        } else if yOffset < 0 {
            scrollView.isScrollEnabled = false
        }
    }
}
