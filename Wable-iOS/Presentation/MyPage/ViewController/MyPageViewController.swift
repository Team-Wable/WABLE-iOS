//
//  MyPageViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/8/24.
//

import Combine
import SafariServices
import UIKit

import SnapKit
import Kingfisher

final class MyPageViewController: UIViewController {
    
    // MARK: - Properties
    
    let customerCenterURL = URL(string: StringLiterals.MyPage.myPageCustomerURL)
    let feedbackURL = URL(string: StringLiterals.MyPage.myPageFeedbackURL)
    
    private var cancelBag = CancelBag()
    var viewModel: MyPageViewModel
//    let homeViewModel = HomeViewModel(networkProvider: NetworkService())
    
    var memberId: Int = loadUserData()?.memberId ?? 0
    var memberProfileImage: String = loadUserData()?.userProfileImage ?? ""
    var contentId: Int = 0
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    var ghostReason: String = ""
    var reportTargetNickname: String = "해당 유저의 닉네임"
    var relateText: String = "마이페이지 유저 신고"
    
    let basicProfileImages: [UIImage : String] = [
        ImageLiterals.Image.imgProfile1 : "PURPLE",
        ImageLiterals.Image.imgProfile2 : "BLUE",
        ImageLiterals.Image.imgProfile3 : "GREEN"
    ]
    
//    var commentDatas: [MyPageMemberCommentResponseDTO] = []
//    var contentDatas: [MyPageMemberContentResponseDTO] = []
    var commentCursor: Int = -1
    var contentCursor: Int = -1
    
    var currentPage: Int = 0 {
        didSet {
            rootView.myPageScrollView.isScrollEnabled = true
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            rootView.pageViewController.setViewControllers(
                [rootView.dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
            let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
            rootView.myPageScrollView.setContentOffset(CGPoint(x: 0, y: -rootView.myPageScrollView.contentInset.top - navigationBarHeight - statusBarHeight), animated: true)
//            rootView.myPagePostViewController.homeFeedTableView.isScrollEnabled = true
            rootView.myPageScrollView.isScrollEnabled = true
        }
    }
    
    var tabBarHeight: CGFloat = 0
    
    // MARK: - UI Components
    
    let rootView = MyPageView()
    private var ghostPopupView: WablePopupView? = nil
    private var logoutPopupView: WablePopupView? = nil
    let refreshControl = UIRefreshControl()

   // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    init(viewModel: MyPageViewModel) {
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
        setAddTarget()
        setRefreshControll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        bindViewModel()
        setNotification()
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.backgroundColor = .wableWhite
        self.tabBarController?.tabBar.barTintColor = .wableWhite
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        // 본인 프로필 화면
        if memberId == loadUserData()?.memberId ?? 0 {
            self.navigationItem.title = loadUserData()?.userNickname ?? ""
            self.tabBarController?.tabBar.isHidden = false
            
            let hambergerButtonImage = ImageLiterals.Button.btnHamberger.withRenderingMode(.alwaysOriginal)
            let hambergerButton = UIBarButtonItem(image: hambergerButtonImage, style: .done, target: self, action: #selector(hambergerButtonDidTapped))
            navigationItem.rightBarButtonItem = hambergerButton
        } else {
            // 타 유저 프로필 화면
            self.navigationItem.title = "타 유저 닉네임"
            self.tabBarController?.tabBar.isHidden = true
            let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
            let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
            navigationItem.leftBarButtonItem = backButton
        }
        
        self.navigationController?.navigationBar.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.barTintColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        removeNotification()
        self.tabBarController?.tabBar.isTranslucent = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight: CGFloat = 70.0
        
        self.tabBarHeight = tabBarHeight + safeAreaHeight
    }
}

// MARK: - Extensions

extension MyPageViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        
        self.rootView.myPageProfileView.profileImageView.load(url: loadUserData()?.userProfileImage ?? "")
        self.rootView.myPageProfileView.userNickname.text = loadUserData()?.userNickname ?? ""
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
        rootView.pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(rootView.segmentedControl.snp.bottom).offset(2.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setNavigationBar() {
        
    }
    
    @objc
    private func hambergerButtonDidTapped() {
        rootView.myPageBottomsheet.showSettings()
    }
    
    @objc
    private func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setDelegate() {
        rootView.myPageScrollView.delegate = self
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(pushViewController), name: MyPagePostViewController.pushViewController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: MyPagePostViewController.reloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContentData(_:)), name: MyPagePostViewController.reloadContentData, object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(warnButtonTapped), name: MyPagePostViewController.warnUserButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contentGhostButtonTapped), name: MyPagePostViewController.ghostButtonTapped, object: nil)
        
//            NotificationCenter.default.addObserver(self, selector: #selector(reloadCommentData(_:)), name: MyPageReplyViewController.reloadCommentData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentGhostButtonTapped), name: MyPageReplyViewController.ghostButtonTapped, object: nil)
        
//            NotificationCenter.default.addObserver(self, selector: #selector(showDeleteToast(_:)), name: DeletePopupViewController.showDeletePostToastNotification, object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(showDeleteToast(_:)), name: DeleteReplyPopupViewController.showDeleteReplyToastNotification, object: nil)
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: MyPagePostViewController.pushViewController, object: nil)
        NotificationCenter.default.removeObserver(self, name: MyPagePostViewController.reloadData, object: nil)
        NotificationCenter.default.removeObserver(self, name: MyPagePostViewController.reloadContentData, object: nil)
//        NotificationCenter.default.removeObserver(self, name: MyPagePostViewController.warnUserButtonTapped, object: nil)
        NotificationCenter.default.removeObserver(self, name: MyPagePostViewController.ghostButtonTapped, object: nil)
        
//        NotificationCenter.default.removeObserver(self, name: MyPageReplyViewController.reloadCommentData, object: nil)
        NotificationCenter.default.removeObserver(self, name: MyPageReplyViewController.ghostButtonTapped, object: nil)
        
//        NotificationCenter.default.removeObserver(self, name: DeletePopupViewController.showDeletePostToastNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: DeleteReplyPopupViewController.showDeleteReplyToastNotification, object: nil)
    }
    
    private func setAddTarget() {
        rootView.segmentedControl.addTarget(self, action: #selector(changeValue(control:)), for: .valueChanged)
        rootView.myPagePostViewController.firstContentButton.addTarget(self, action: #selector(goToWriteViewController), for: .touchUpInside)
        rootView.myPageProfileView.editButton.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.accountInfoButton.addTarget(self, action: #selector(accountInfoButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.settingAlarmButton.addTarget(self, action: #selector(settingAlarmButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.feedbackButton.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.customerCenterButton.addTarget(self, action: #selector(customerCenterButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    private func setRefreshControll() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        rootView.myPageScrollView.refreshControl = refreshControl
        refreshControl.tintColor = .gray300
        refreshControl.backgroundColor = .wableWhite
    }
    
    @objc
    func refreshData() {
        DispatchQueue.main.async {
            self.contentCursor = -1
            self.commentCursor = -1
            self.bindViewModel()
        }
        self.perform(#selector(self.finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    func finishedRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func bindViewModel() {
        let input = MyPageViewModel.Input(viewUpdate: Just((1, self.memberId, self.commentCursor, self.contentCursor)).eraseToAnyPublisher())
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.getProfileData
            .receive(on: RunLoop.main)
            .sink { data in
                self.rootView.myPagePostViewController.profileData = self.viewModel.myPageProfileData
                self.rootView.myPageReplyViewController.profileData = self.viewModel.myPageProfileData
                self.bindProfileData(data: data)
            }
            .store(in: self.cancelBag)
        
        output.getContentData
            .receive(on: RunLoop.main)
            .sink { data in
                self.rootView.myPagePostViewController.contentDatas = data
                self.viewModel.contentCursor = self.contentCursor
                if data.isEmpty {
                    self.viewModel.contentCursor = -1
                } else {
                    self.viewModel.contentCursor = self.contentCursor
                }
                if !data.isEmpty {
                    self.rootView.myPagePostViewController.noContentLabel.isHidden = true
                    self.rootView.myPagePostViewController.firstContentButton.isHidden = true
                } else {
                    if loadUserData()?.memberId != self.memberId {
                        self.rootView.myPagePostViewController.noContentLabel.isHidden = false
                        self.rootView.myPagePostViewController.firstContentButton.isHidden = true
                    } else {
                        self.rootView.myPagePostViewController.noContentLabel.isHidden = false
                        self.rootView.myPagePostViewController.firstContentButton.isHidden = false
                    }
                }
                DispatchQueue.main.async {
                    self.rootView.myPagePostViewController.homeFeedTableView.reloadData()
                }
            }
            .store(in: self.cancelBag)
        
        output.getCommentData
            .receive(on: RunLoop.main)
            .sink { data in
                self.rootView.myPageReplyViewController.commentDatas = data
                if !data.isEmpty {
                    self.rootView.myPageReplyViewController.noCommentLabel.isHidden = true
                } else {
                    self.rootView.myPageReplyViewController.noCommentLabel.isHidden = false
                }
                DispatchQueue.main.async {
                    self.rootView.myPageReplyViewController.feedDetailTableView.reloadData()
                }
            }
            .store(in: self.cancelBag)
    }
    
    private func bindProfileData(data: MypageProfileResponseDTO) {
        self.rootView.myPageProfileView.userNickname.text = data.nickname
        self.rootView.myPageProfileView.profileImageView.load(url: data.memberProfileUrl)
        self.rootView.myPageProfileView.transparencyValue = data.memberGhost
        self.rootView.myPageProfileView.userIntroductionLabel.setTextWithLineHeight(
            text: "\(data.memberFanTeam)을(를) 응원하고 있어요.\n\(data.memberLckYears)년부터 LCK를 보기 시작했어요.",
            lineHeight: 25.adjusted, alignment: .left
        )
        
        if data.memberId != loadUserData()?.memberId ?? 0 {
            self.rootView.myPagePostViewController.noContentLabel.text = "아직 \(data.nickname)" + StringLiterals.MyPage.myPageNoContentOtherLabel
            self.rootView.myPageReplyViewController.noCommentLabel.text = "아직 \(data.nickname)" + StringLiterals.MyPage.myPageNoCommentOtherLabel
        } else {
            self.rootView.myPagePostViewController.noContentLabel.text = "\(data.nickname)" + StringLiterals.MyPage.myPageNoContentLabel
            self.rootView.myPageReplyViewController.noCommentLabel.text = StringLiterals.MyPage.myPageNoCommentLabel
            
            saveUserData(UserInfo(isSocialLogined: true,
                                  isFirstUser: false,
                                  isJoinedApp: true,
                                  userNickname: data.nickname,
                                  memberId: loadUserData()?.memberId ?? 0,
                                  userProfileImage: data.memberProfileUrl,
                                  fcmToken: loadUserData()?.fcmToken ?? "",
                                  isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
        }
    }
    
    @objc
    private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }
    
    @objc
    private func goToWriteViewController() {
        let viewController = WriteViewController(viewModel: WriteViewModel(networkProvider: NetworkService()))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func profileEditButtonTapped() {
        rootView.myPageBottomsheet.handleDismiss()
        
        let vc = MyPageEditProfileViewController(viewModel: MyPageProfileViewModel(networkProvider: NetworkService()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func accountInfoButtonTapped() {
        rootView.myPageBottomsheet.handleDismiss()
        
        let vc = MyPageAccountInfoViewController(viewModel: MyPageAccountInfoViewModel(networkProvider: NetworkService()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func settingAlarmButtonTapped() {
        rootView.myPageBottomsheet.handleDismiss()
        
        let vc = MyPageSettingAlarmViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func feedbackButtonTapped() {
        rootView.myPageBottomsheet.handleDismiss()
        let feedbackView: SFSafariViewController
        if let feedbackURL = self.feedbackURL {
            feedbackView = SFSafariViewController(url: feedbackURL)
            self.present(feedbackView, animated: true, completion: nil)
        }
    }
    
    @objc
    private func customerCenterButtonTapped() {
        rootView.myPageBottomsheet.handleDismiss()
        let customerCenterView: SFSafariViewController
        if let customerCenterURL = self.customerCenterURL {
            customerCenterView = SFSafariViewController(url: customerCenterURL)
            self.present(customerCenterView, animated: true, completion: nil)
        }
    }
    
    @objc
    private func logoutButtonTapped() {
        self.logoutPopupView = WablePopupView(popupTitle: StringLiterals.MyPage.myPageLogoutPopupTitleLabel,
                                              popupContent: "",
                                              leftButtonTitle: StringLiterals.MyPage.myPageLogoutPopupLeftButtonTitle,
                                              rightButtonTitle: StringLiterals.MyPage.myPageLogoutPopupRightButtonTitle)
        
        if let popupView = self.logoutPopupView {
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
    private func pushViewController(_ notification: Notification) {
        let detailViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()))
        detailViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
//        if let contentId = notification.userInfo?["contentId"] as? Int, let profileImageURL = notification.userInfo?["profileImageURL"] as? String {
//            let detailViewController = FeedDetailViewController()
//            detailViewController.hidesBottomBarWhenPushed = true
//            destinationViewController.contentId = contentId
//            destinationViewController.userProfileURL = profileImageURL
//            self.navigationController?.pushViewController(detailViewController, animated: true)
//        }
    }
    
    @objc
    func reloadData(_ notification: Notification) {
        bindViewModel()
    }
    
    @objc
    func reloadContentData(_ notification: Notification) {
        self.contentCursor = notification.userInfo?["contentCursor"] as? Int ?? -1
        bindViewModel()
    }
    
    @objc
    private func contentGhostButtonTapped() {
//        self.alarmTriggerType = rootView.myPageContentViewController.alarmTriggerType
//        self.targetMemberId = rootView.myPageContentViewController.targetMemberId
//        self.alarmTriggerdId = rootView.myPageContentViewController.alarmTriggerdId
        
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
        
//
//        if let window = UIApplication.shared.keyWindowInConnectedScenes {
//            window.addSubviews(transparentReasonView)
//            
//            transparentReasonView.snp.makeConstraints {
//                $0.edges.equalToSuperview()
//            }
//            
//            let radioButtonImage = ImageLiterals.TransparencyInfo.btnRadio
//            
//            self.transparentReasonView.firstReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.secondReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.thirdReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.fourthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.fifthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.sixthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.warnLabel.isHidden = true
//            self.ghostReason = ""
//        }
    }
    
    @objc
    private func commentGhostButtonTapped() {
        self.alarmTriggerType = rootView.myPageReplyViewController.alarmTriggerType
        self.targetMemberId = rootView.myPageReplyViewController.targetMemberId
        self.alarmTriggerdId = rootView.myPageReplyViewController.alarmTriggerdId
        
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
//
//        if let window = UIApplication.shared.keyWindowInConnectedScenes {
//            window.addSubviews(transparentReasonView)
//            
//            transparentReasonView.snp.makeConstraints {
//                $0.edges.equalToSuperview()
//            }
//            
//            let radioButtonImage = ImageLiterals.TransparencyInfo.btnRadio
//            
//            self.transparentReasonView.firstReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.secondReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.thirdReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.fourthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.fifthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.sixthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//            self.transparentReasonView.warnLabel.isHidden = true
//            self.ghostReason = ""
//        }
    }
}

extension MyPageViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var yOffset = scrollView.contentOffset.y
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        scrollView.isScrollEnabled = true
        rootView.myPagePostViewController.homeFeedTableView.isScrollEnabled = false
        rootView.myPageReplyViewController.feedDetailTableView.isScrollEnabled = false
        
        if yOffset <= -(navigationBarHeight + statusBarHeight) {
            rootView.myPagePostViewController.homeFeedTableView.isScrollEnabled = false
            rootView.myPageReplyViewController.feedDetailTableView.isScrollEnabled = false
            yOffset = -(navigationBarHeight + statusBarHeight)
            rootView.segmentedControl.frame.origin.y = yOffset + statusBarHeight + navigationBarHeight
            rootView.segmentedControl.snp.remakeConstraints {
                $0.top.equalTo(rootView.myPageProfileView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(54.adjusted)
            }
            
            rootView.pageViewController.view.snp.remakeConstraints {
                $0.top.equalTo(rootView.segmentedControl.snp.bottom).offset(2.adjusted)
                $0.leading.trailing.equalToSuperview()
                let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
                $0.height.equalTo(UIScreen.main.bounds.height - statusBarHeight - navigationBarHeight - self.tabBarHeight)
            }
        } else if yOffset >= (rootView.myPageProfileView.frame.height - statusBarHeight - navigationBarHeight) {
            rootView.segmentedControl.frame.origin.y = yOffset - rootView.myPageProfileView.frame.height + statusBarHeight + navigationBarHeight
            rootView.segmentedControl.snp.remakeConstraints {
                $0.top.equalTo(rootView.myPageProfileView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(54.adjusted)
            }
            
            rootView.pageViewController.view.frame.origin.y = yOffset - rootView.myPageProfileView.frame.height + statusBarHeight + navigationBarHeight + rootView.segmentedControl.frame.height
            
            rootView.pageViewController.view.snp.remakeConstraints {
                $0.top.equalTo(rootView.segmentedControl.snp.bottom).offset(2.adjusted)
                $0.leading.trailing.equalToSuperview()
                let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
                $0.height.equalTo(UIScreen.main.bounds.height - statusBarHeight - navigationBarHeight - self.tabBarHeight)
            }
            
            scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
            
            rootView.myPagePostViewController.homeFeedTableView.isScrollEnabled = true
            rootView.myPagePostViewController.homeFeedTableView.isUserInteractionEnabled = true
            rootView.myPageReplyViewController.feedDetailTableView.isScrollEnabled = true
            rootView.myPageReplyViewController.feedDetailTableView.isUserInteractionEnabled = true
        }
    }
}

extension MyPageViewController: WablePopupDelegate {
    func cancleButtonTapped() {
        if ghostPopupView != nil {
            self.ghostPopupView?.removeFromSuperview()
        }
        
        if logoutPopupView != nil {
            self.logoutPopupView?.removeFromSuperview()
        }
    }
    
    func confirmButtonTapped() {
        if ghostPopupView != nil {
            self.ghostPopupView?.removeFromSuperview()
            print("투명도 버튼 클릭: 서버통신 이후에 투명도 낮추도록 하기")
        }
        
        if logoutPopupView != nil {
            self.logoutPopupView?.removeFromSuperview()
            self.rootView.myPageBottomsheet.handleDismiss()
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                DispatchQueue.main.async {
                    let rootViewController = LoginViewController(viewModel: LoginViewModel(networkProvider: NetworkService()))
                    sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: rootViewController)
                }
            }
            
            saveUserData(UserInfo(isSocialLogined: false,
                                  isFirstUser: false,
                                  isJoinedApp: true,
                                  userNickname: loadUserData()?.userNickname ?? "",
                                  memberId: loadUserData()?.memberId ?? 0,
                                  userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                                  fcmToken: loadUserData()?.fcmToken ?? "",
                                  isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
        }
    }
}
