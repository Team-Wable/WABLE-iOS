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
    
    static let pushViewController = NSNotification.Name("pushViewController")
    static let reloadData = NSNotification.Name("reloadData")
    static let warnUserButtonTapped = NSNotification.Name("warnUserButtonTapped")
    static let ghostButtonTapped = NSNotification.Name("ghostButtonTappedButtonContentTapped")
    static let reloadContentData = NSNotification.Name("reloadContentData")
    
    var showUploadToastView: Bool = false
    private let refreshControl = UIRefreshControl()
    
    private let viewModel: HomeViewModel
    private let likeViewModel: LikeViewModel
    private let myPageViewModel: MyPageViewModel
    private var cancelBag = CancelBag()
    
    var profileData: [MypageProfileResponseDTO] = []
    var contentDatas: [HomeFeedDTO] = []
    // var contentData = MyPageViewModel(networkProvider: NetworkService()).myPageContentDatas
    
    var contentId: Int = 0
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    var reportTargetNickname = ""
    var relateText = ""
    let warnUserURL = URL(string: StringLiterals.Network.warnUserGoogleFormURL)
    
    var nowShowingPopup: String = ""
    
    // MARK: - UI Components
    
    var homeBottomsheetView = HomeBottomSheetView()
    private var reportPopupView: WablePopupView? = nil
    private var deletePopupView: WablePopupView? = nil
    
    private var reportToastView: UIImageView?
    
    lazy var homeFeedTableView = HomeView().feedTableView
    var noContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray500
        label.font = .body2
        label.numberOfLines = 2
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    let firstContentButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.MyPage.myPageNoContentButton, for: .normal)
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
    
    init(viewModel: HomeViewModel, likeViewModel: LikeViewModel, myPageViewModel: MyPageViewModel) {
        self.viewModel = viewModel
        self.likeViewModel = likeViewModel
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
            $0.top.equalToSuperview().inset(30.adjusted)
            $0.leading.trailing.equalToSuperview().inset(20.adjusted)
        }
        
        firstContentButton.snp.makeConstraints {
            $0.top.equalTo(noContentLabel.snp.bottom).offset(36.adjusted)
            $0.leading.trailing.equalToSuperview().inset(48.adjusted)
            $0.height.equalTo(48.adjusted)
        }
    }
    
    private func setDelegate() {
        homeFeedTableView.dataSource = self
        homeFeedTableView.delegate = self
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: MyPagePostViewController.reloadData, object: nil)
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
        // 최초 한 번만 publisher 생성
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?  = Just(())
                .map { _ in return (isClicked, contentId) }
                .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
                .eraseToAnyPublisher()
        
        let input = LikeViewModel.Input(likeButtonTapped: likeButtonTapped, commentLikeButtonTapped: nil, deleteButtonDidTapped: nil, deleteReplyButtonDidTapped: nil)

        let output = self.likeViewModel.transform(from: input, cancelBag: self.cancelBag)

        output.toggleLikeButton
            .sink { _ in }
            .store(in: self.cancelBag)
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
    
    func getContentData(at index: Int) -> HomeFeedDTO? {
        guard index >= 0 && index < contentDatas.count else { return nil }
        return contentDatas[index]
    }
}

extension MyPagePostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeFeedTableView.dequeueReusableCell(withIdentifier: HomeFeedTableViewCell.identifier, for: indexPath) as? HomeFeedTableViewCell ?? HomeFeedTableViewCell()
        cell.selectionStyle = .none
        
        cell.alarmTriggerType = "contentGhost"
        cell.targetMemberId = contentDatas[indexPath.row].memberID
        cell.alarmTriggerdId = contentDatas[indexPath.row].contentID ?? Int()
        
        if contentDatas[indexPath.row].memberID == loadUserData()?.memberId {
            print("contentDatas[indexPath.row].memberId == loadUserData()?.memberId")
            cell.bottomView.ghostButton.isHidden = true
            
            cell.menuButtonTapped = {
                self.homeBottomsheetView.showSettings()
                self.homeBottomsheetView.reportButton.isHidden = true
                self.homeBottomsheetView.deleteButton.isHidden = false
                
                self.reportTargetNickname = self.contentDatas[indexPath.row].memberNickname
                self.relateText = self.contentDatas[indexPath.row].contentText ?? ""
                self.homeBottomsheetView.deleteButton.addTarget(self, action: #selector(self.deletePostButtonTapped), for: .touchUpInside)
                self.contentId = self.contentDatas[indexPath.row].contentID ?? Int()
                self.nowShowingPopup = "delete"
            }
        } else {
            print("contentDatas[indexPath.row].memberId != loadUserData()?.memberId")
            // 다른 유저인 경우
            cell.bottomView.ghostButton.isHidden = false
            
            cell.menuButtonTapped = {
                self.homeBottomsheetView.showSettings()
                self.homeBottomsheetView.reportButton.isHidden = false
                self.homeBottomsheetView.deleteButton.isHidden = true
                
                self.reportTargetNickname = self.contentDatas[indexPath.row].memberNickname
                self.relateText = self.contentDatas[indexPath.row].contentText ?? ""
                self.homeBottomsheetView.reportButton.addTarget(self, action: #selector(self.reportButtonTapped), for: .touchUpInside)
                self.nowShowingPopup = "report"
            }
        }
        
        cell.bind(data: contentDatas[indexPath.row])
        
        cell.profileButtonAction = {
            let memberId = self.contentDatas[indexPath.row].memberID

            if memberId == loadUserData()?.memberId ?? 0  {
                self.tabBarController?.selectedIndex = 3
            } else {
                let viewController = MyPageViewController(viewModel: MyPageViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
                viewController.memberId = memberId
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        cell.bottomView.ghostButtonTapped = { [weak self] in
            self?.alarmTriggerType = cell.alarmTriggerType
            self?.targetMemberId = cell.targetMemberId
            self?.alarmTriggerdId = cell.alarmTriggerdId
            NotificationCenter.default.post(name: MyPagePostViewController.ghostButtonTapped, object: nil)
        }
        
        cell.bottomView.heartButtonTapped = {
            var currentHeartCount = cell.bottomView.heartButton.titleLabel?.text
            
            if cell.bottomView.isLiked == true {
                cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) - 1)", font: .caption1, textColor: .wableBlack)
            } else {
                cell.bottomView.heartButton.setTitleWithConfiguration("\((Int(currentHeartCount ?? "") ?? 0) + 1)", font: .caption1, textColor: .wableBlack)
            }
            self.postLikeButtonAPI(isClicked: cell.bottomView.isLiked, contentId: self.contentDatas[indexPath.row].contentID ?? Int())
            
            cell.bottomView.isLiked.toggle()
            
        }
        
        cell.bottomView.commentButton.isEnabled = true
        
        cell.bottomView.commentButtonTapped = { [weak self] in
            guard let self = self else { return }

            let contentId = self.contentDatas[indexPath.row].contentID
            
            NotificationCenter.default.post(name: MyPagePostViewController.pushViewController, object: nil, userInfo: ["data": self.contentDatas[indexPath.row], "contentID": contentId])
        }
        
        var memberGhost = self.contentDatas[indexPath.row].memberGhost
        memberGhost = adjustGhostValue(memberGhost)
        
        cell.grayView.layer.zPosition = 1
        
        // 내가 투명도를 누른 유저인 경우 -85% 적용
        if self.contentDatas[indexPath.row].isGhost {
            cell.grayView.alpha = 0.85
        } else {
            cell.grayView.alpha = CGFloat(Double(-memberGhost) / 100)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contentId = contentDatas[indexPath.row].contentID
        NotificationCenter.default.post(name: MyPagePostViewController.pushViewController, object: nil, userInfo: ["data": self.contentDatas[indexPath.row], "contentID": contentId])
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == homeFeedTableView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height) {
                let lastCommentId = contentDatas.last?.contentID ?? -1
                myPageViewModel.contentCursor = lastCommentId
                NotificationCenter.default.post(name: MyPageReplyViewController.reloadCommentData, object: nil, userInfo: ["contentCursor": lastCommentId])
                DispatchQueue.main.async {
                     self.homeFeedTableView.reloadData()
                }
            }
        }
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

extension MyPagePostViewController: WablePopupDelegate {
    
    func cancelButtonTapped() {
//        if ghostPopupView != nil {
//            self.ghostPopupView?.removeFromSuperview()
//        }
        
        if reportPopupView != nil {
            self.reportPopupView?.removeFromSuperview()
        }
        
        if deletePopupView != nil {
            self.deletePopupView?.removeFromSuperview()
        }
    }
    
    func confirmButtonTapped() {
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
                        
                        NotificationCenter.default.post(name: MyPagePostViewController.reloadData, object: nil)
                        
                        UIView.animate(withDuration: 0.3) {
                            self.homeFeedTableView.contentOffset.y = 0
                        }
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
