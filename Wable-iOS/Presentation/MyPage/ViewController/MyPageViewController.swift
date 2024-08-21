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
    var reportTargetNickname: String = ""
    var relateText: String = "마이페이지 유저 신고"
    
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
//            rootView.myPagePostViewController.homeCollectionView.isScrollEnabled = true
            rootView.myPageScrollView.isScrollEnabled = true
        }
    }
    
    var tabBarHeight: CGFloat = 0
    
    // MARK: - UI Components
    
    let rootView = MyPageView()
    let refreshControl = UIRefreshControl()
    private var navigationBackButton = BackButton()
    private var navigationHambergerButton = HambergerButton()

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
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationHambergerButton.isHidden = false
        
        self.navigationController?.navigationBar.addSubviews(navigationBackButton, navigationHambergerButton)
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
    }
    
    private func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton, navigationHambergerButton)
        
        // 본인 프로필 화면
//        if memberId == loadUserData()?.memberId ?? 0 {
//            navigationHambergerButton.isHidden = false
//        } else {
//            navigationBackButton.isHidden = false
//        }
    }
    
    private func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        
        navigationHambergerButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12.adjusted)
        }
        
        rootView.pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(rootView.segmentedControl.snp.bottom).offset(2.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setDelegate() {
        rootView.myPageScrollView.delegate = self
    }
    
    private func setNotification() {
        
    }
    
    private func removeNotification() {
       
    }
    
    private func setAddTarget() {
        self.navigationHambergerButton.addTarget(self, action: #selector(myPageHambergerButtonTapped), for: .touchUpInside)
        rootView.segmentedControl.addTarget(self, action: #selector(changeValue(control:)), for: .valueChanged)
        rootView.myPageProfileView.editButton.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.accountInfoButton.addTarget(self, action: #selector(accountInfoButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.settingAlarmButton.addTarget(self, action: #selector(settingAlarmButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.feedbackButton.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.customerCenterButton.addTarget(self, action: #selector(customerCenterButtonTapped), for: .touchUpInside)
        rootView.myPageBottomsheet.logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    private func setRefreshControll() {
        
    }
    
    func bindViewModel() {
        let input = MyPageViewModel.Input(viewUpdate: Just((1, self.memberId, self.commentCursor, self.contentCursor)).eraseToAnyPublisher())
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        self.rootView.myPageProfileView.transparencyValue = -15
    }
    
    @objc
    private func myPageHambergerButtonTapped() {
        rootView.myPageBottomsheet.showSettings()
    }
    
    @objc
    private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }
    
    @objc
    private func profileEditButtonTapped() {
        rootView.myPageBottomsheet.handleDismiss()
        navigationHambergerButton.isHidden = true
        
        let vc = MyPageEditProfileViewController(viewModel: MyPageProfileViewModel())
//        vc.memberId = self.memberId
//        vc.nickname = self.rootView.myPageProfileView.userNickname.text ?? ""
//        vc.introText = self.rootView.myPageProfileView.userIntroduction.text ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func accountInfoButtonTapped() {
        rootView.myPageBottomsheet.handleDismiss()
        navigationHambergerButton.isHidden = true
        
        let vc = MyPageAccountInfoViewController(viewModel: MyPageAccountInfoViewModel())
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
//        showLogoutPopupView()
    }
}

extension MyPageViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var yOffset = scrollView.contentOffset.y
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        scrollView.isScrollEnabled = true
//        rootView.myPageContentViewController.homeCollectionView.isScrollEnabled = false
//        rootView.myPageCommentViewController.homeCollectionView.isScrollEnabled = false
        
        if yOffset <= -(navigationBarHeight + statusBarHeight) {
//            rootView.myPageContentViewController.homeCollectionView.isScrollEnabled = false
//            rootView.myPageCommentViewController.homeCollectionView.isScrollEnabled = false
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
            
//            rootView.myPageContentViewController.homeCollectionView.isScrollEnabled = true
//            rootView.myPageContentViewController.homeCollectionView.isUserInteractionEnabled = true
//            rootView.myPageCommentViewController.homeCollectionView.isScrollEnabled = true
//            rootView.myPageCommentViewController.homeCollectionView.isUserInteractionEnabled = true
        }
    }
}
