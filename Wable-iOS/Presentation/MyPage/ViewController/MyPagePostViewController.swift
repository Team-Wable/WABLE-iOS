//
//  MyPagePostViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/19/24.
//

import Combine
import SafariServices
import UIKit

import SnapKit

final class MyPagePostViewController: UIViewController {
    
    // MARK: - Properties
    
    let dummyData: [HomeFeedDTO] = [HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "냐옹",
                                                contentID: 1, contentTitle: "contentTitle",
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!)여기서끝인줄 알았다면 아주 만만의 콩떡이시다 나는 여기서 더더더더덛 긴 글을 한번 써볼건데 내 생각으로는 안될 것 같다는 느낌느낌.... 아니 얘는 또 잘 되자나.... ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 10,
                                                        commentNumber: 22,
                                                        isDeleted: false,
                                                        contentImageURL: "",
                                                        memberFanTeam: "DRX"),
                                        HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "먀옹",
                                                    contentID: 1, contentTitle: "contentTitle",
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 9,
                                                        commentNumber: 8,
                                                        isDeleted: false,
                                                        contentImageURL: "",
                                                        memberFanTeam: "T1"),
                                        HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "뭐임마",
                                                        contentID: 1, contentTitle: "contentTitle",
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) 어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) 어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 4,
                                                        commentNumber: 93,
                                                        isDeleted: false,
                                                        contentImageURL: nil,
                                                        memberFanTeam: "GEN"),
                                        HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "냐옹",
                                                        contentID: 1, contentTitle: "contentTitle",
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 10,
                                                        commentNumber: 22,
                                                        isDeleted: false,
                                                        contentImageURL: "",
                                                        memberFanTeam: "DRX")
    ]
    
    static let pushViewController = NSNotification.Name("pushViewController")
    static let reloadData = NSNotification.Name("reloadData")
    static let warnUserButtonTapped = NSNotification.Name("warnUserButtonTapped")
    static let ghostButtonTapped = NSNotification.Name("ghostButtonTappedButtonContentTapped")
    static let reloadContentData = NSNotification.Name("reloadContentData")
    
    var showUploadToastView: Bool = false
    private let refreshControl = UIRefreshControl()
    
    private let viewModel: HomeViewModel
    private let myPageViewModel: MyPageViewModel
    private var cancelBag = CancelBag()
    
//    var profileData: [MypageProfileResponseDTO] = []
//    var contentDatas: [MyPageMemberContentResponseDTO] = []
    // var contentData = MyPageViewModel(networkProvider: NetworkService()).myPageContentDatas
    
    var contentId: Int = 0
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    
    // MARK: - UI Components
    
    lazy var homeFeedTableView = HomeView().feedTableView
    var noContentLabel: UILabel = {
        let label = UILabel()
        label.text = "StringLiterals.MyPage.myPageNoContentLabel"
        label.textColor = .gray500
        label.font = .body2
        label.numberOfLines = 2
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    let firstContentButton: UIButton = {
        let button = UIButton()
        button.setTitle("글 작성하러 가기", for: .normal)
        button.setTitleColor(.wableWhite, for: .normal)
        button.titleLabel?.font = .body1
        button.backgroundColor = .purple50
        button.layer.cornerRadius = 12.adjusted
        button.isHidden = true
        return button
    }()
    
//    var deletePostPopupVC = DeletePopupViewController(viewModel: DeletePostViewModel(networkProvider: NetworkService()))
//    var warnBottomsheet = DontBeBottomSheetView(singleButtonImage: ImageLiterals.Posting.btnWarn)
    
    // MARK: - Life Cycles
    
    init(viewModel: HomeViewModel, myPageViewModel: MyPageViewModel) {
        self.viewModel = viewModel
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setRefreshControll()
        setNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self, name: MyPageContentViewController.reloadData, object: nil)
    }
}

// MARK: - Extensions

extension MyPagePostViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = true
        
//        deletePostPopupVC.modalPresentationStyle = .overFullScreen
    }
    
    private func setHierarchy() {
        view.addSubviews(homeFeedTableView, noContentLabel, firstContentButton)
    }
    
    private func setLayout() {
        homeFeedTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        noContentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(44.adjusted)
            $0.leading.trailing.equalToSuperview().inset(20.adjusted)
        }
        
        firstContentButton.snp.makeConstraints {
            $0.top.equalTo(noContentLabel.snp.bottom).offset(20.adjusted)
            $0.leading.trailing.equalToSuperview().inset(112.adjusted)
            $0.height.equalTo(44.adjusted)
        }
    }
    
    private func setDelegate() {
        homeFeedTableView.dataSource = self
        homeFeedTableView.delegate = self
    }
    
    private func setNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: MyPageContentViewController.reloadData, object: nil)
    }
    
    private func setRefreshControll() {
        refreshControl.addTarget(self, action: #selector(refreshPostDidDrag), for: .valueChanged)
        homeFeedTableView.refreshControl = refreshControl
        refreshControl.backgroundColor = .wableWhite
    }
    
    @objc
    func reloadData(_ notification: Notification) {
        refreshPostDidDrag()
    }
    
    @objc
    func refreshPostDidDrag() {
        DispatchQueue.main.async {
            self.homeFeedTableView.reloadData()
        }
        self.perform(#selector(self.finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    func finishedRefreshing() {
        refreshControl.endRefreshing()
    }
    
    @objc
    private func deleteButtonTapped() {
        popDeleteView()
        presentView()
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
//        deletePostPopupVC.contentId = self.contentId
//        self.present(self.deletePostPopupVC, animated: false, completion: nil)
    }
    
    private func postLikeButtonAPI(isClicked: Bool, contentId: Int) {
//        // 최초 한 번만 publisher 생성
//        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?  = Just(())
//                .map { _ in return (!isClicked, contentId) }
//                .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
//                .eraseToAnyPublisher()
//
//        let input = HomeViewModel.Input(
//            viewUpdate: nil,
//            likeButtonTapped: likeButtonTapped,
//            firstReasonButtonTapped: nil,
//            secondReasonButtonTapped: nil,
//            thirdReasonButtonTapped: nil,
//            fourthReasonButtonTapped: nil,
//            fifthReasonButtonTapped: nil,
//            sixthReasonButtonTapped: nil,
//            isPushNotiAllowed: nil)
//
//        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
//
//        output.toggleLikeButton
//            .sink { _ in }
//            .store(in: self.cancelBag)
    }
}

extension MyPagePostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeFeedTableView.dequeueReusableCell(withIdentifier: HomeFeedTableViewCell.identifier, for: indexPath) as? HomeFeedTableViewCell ?? HomeFeedTableViewCell()
        cell.selectionStyle = .none
        cell.bind(data: dummyData[indexPath.row])
        
        cell.bottomView.commentButtonTapped = { [weak self] in
            self?.viewModel.commentButtonTapped.send(indexPath.row)
        }
        
        cell.bottomView.ghostButtonTapped = { [weak self] in
//            self.alarmTriggerType = cell.alarmTriggerType
//            self.targetMemberId = cell.targetMemberId
//            self.alarmTriggerdId = cell.alarmTriggerdId
            NotificationCenter.default.post(name: MyPagePostViewController.ghostButtonTapped, object: nil)
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
//        let contentId = contentDatas[indexPath.row].contentId
//        let profileImageURL = contentDatas[indexPath.row].memberProfileUrl
//        NotificationCenter.default.post(name: MyPagePostViewController.pushViewController, object: nil, userInfo: ["contentId": contentId, "profileImageURL": profileImageURL])
        NotificationCenter.default.post(name: MyPagePostViewController.pushViewController, object: nil)
        
//        let detailViewController = FeedDetailViewController()
//        detailViewController.hidesBottomBarWhenPushed = true
//        detailViewController.getFeedData(data: dummyData[indexPath.row])
//        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension MyPagePostViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if yOffset > 0 {
            scrollView.isScrollEnabled = true
        } else if yOffset < 0 {
            scrollView.isScrollEnabled = false
        }
    }
}
