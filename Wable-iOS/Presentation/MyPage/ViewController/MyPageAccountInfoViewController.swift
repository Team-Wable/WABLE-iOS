//
//  MyPageAccountInfoViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/20/24.
//

import Combine
import SafariServices
import UIKit

import SnapKit

final class MyPageAccountInfoViewController: UIViewController {
    
    // MARK: - Properties
    
    let userTermURL = URL(string: StringLiterals.MyPage.myPageUseTermURL)
    
    private var cancelBag = CancelBag()
    private let viewModel: MyPageAccountInfoViewModel
    
    private lazy var backButtonTapped = self.navigationBackButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var signOutButtonTapped = self.signOutButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    var titleData = [
        "소셜 로그인",
        "버전 정보",
        "아이디",
        "가입일",
        "이용약관"
    ]
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    
    private let topDivisionLine = UIView().makeDivisionLine()
    
    private let accountInfoTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = true
        tableView.backgroundColor = .wableWhite
        return tableView
    }()
    
    let infoTitle: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.text = "이용약관"
        label.textColor = .gray600
        return label
    }()
    
    let moreInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle("자세히 보기", for: .normal)
        button.setTitleColor(.wableBlack, for: .normal)
        button.titleLabel?.font = .body2
        return button
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.MyPage.myPageSignOutButtonTitle, for: .normal)
        button.setTitleColor(.error, for: .normal)
        button.titleLabel?.font = .body4
        return button
    }()
    
    // MARK: - Life Cycles
    
    init(viewModel: MyPageAccountInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAddTarget()
        setDelegate()
        setRegisterCell()
        bindViewModel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
    }
}

// MARK: - Extensions

extension MyPageAccountInfoViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        
        addUnderline(to: moreInfoButton)
    }
    
    private func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton)
        
        self.view.addSubviews(topDivisionLine,
                              accountInfoTableView,
                              infoTitle,
                              moreInfoButton,
                              signOutButton)
    }
    
    private func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        
        topDivisionLine.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
        }
        
        accountInfoTableView.snp.makeConstraints {
            $0.top.equalTo(topDivisionLine.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo((58.adjusted * 4))
        }
        
        infoTitle.snp.makeConstraints {
            $0.top.equalTo(accountInfoTableView.snp.bottom).offset(19.adjusted)
            $0.leading.equalToSuperview().inset(26.adjusted)
        }
        
        moreInfoButton.snp.makeConstraints {
            $0.centerY.equalTo(infoTitle.snp.centerY)
            $0.leading.equalToSuperview().inset(159.adjusted)
        }
        
        signOutButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-29.adjusted)
        }
    }
    
    private func setAddTarget() {
        moreInfoButton.addTarget(self, action: #selector(moreInfoTapped), for: .touchUpInside)
    }
    
    private func setDelegate() {
        self.accountInfoTableView.dataSource = self
        self.accountInfoTableView.delegate = self
    }
    
    private func setRegisterCell() {
        self.accountInfoTableView.register(MyPageAccountInfoTableViewCell.self, forCellReuseIdentifier: "MyPageAccountInfoTableViewCell")
    }
    
    private func setDataBind() {
        
    }
    
    private func bindViewModel() {
        let memberId = loadUserData()?.memberId ?? 0
        let input = MyPageAccountInfoViewModel.Input(
            backButtonTapped: backButtonTapped,
            viewAppear: Just(()).eraseToAnyPublisher(),
            signOutButtonTapped: signOutButtonTapped)
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else if value == 1 {
                    let vc = MyPageSignOutViewController(viewModel: MyPageSignOutReasonViewModel())
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .store(in: self.cancelBag)
        
        output.getAccountInfoData
            .receive(on: RunLoop.main)
            .sink { _ in
                self.accountInfoTableView.reloadData()
            }
            .store(in: self.cancelBag)
        
        output.isSignOutResult
            .sink { result in
                if result == 200 {
                    DispatchQueue.main.async {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            DispatchQueue.main.async {
                                let rootViewController = LoginViewController(viewModel: LoginViewModel())
                                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: rootViewController)
                            }
                        }
                        
                        saveUserData(UserInfo(isSocialLogined: false,
                                              isFirstUser: false,
                                              isJoinedApp: true,
                                              isOnboardingFinished: true,
                                              userNickname: loadUserData()?.userNickname ?? "",
                                              memberId: loadUserData()?.memberId ?? 0,
                                              userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                                              fcmToken: loadUserData()?.fcmToken ?? "",
                                              isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
                    }
                } else if result == 400 {
                    print("존재하지 않는 요청입니다.")
                } else {
                    print("서버 내부에서 오류가 발생했습니다.")
                }
            }
            .store(in: self.cancelBag)
    }
    
    func addUnderline(to button: UIButton) {
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.wableBlack
        ]

        let attributedString = NSAttributedString(string: button.currentTitle ?? "", attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
    }
    
    @objc private func moreInfoTapped() {
        let useTermView: SFSafariViewController
        if let useTermURL = self.userTermURL {
            useTermView = SFSafariViewController(url: useTermURL)
            self.present(useTermView, animated: true, completion: nil)
        }
    }
}

extension MyPageAccountInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.adjusted
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6.adjusted
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

extension MyPageAccountInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.myPageMemberData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageAccountInfoTableViewCell", for: indexPath) as! MyPageAccountInfoTableViewCell
        cell.backgroundColor = .wableWhite
        cell.selectionStyle = .none
        cell.infoTitle.text = titleData[indexPath.row]
        cell.infoContent.text = viewModel.myPageMemberData[indexPath.row]
        return cell
    }
}
