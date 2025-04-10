//
//  AgreementViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/21/25.
//


import Combine
import SafariServices
import UIKit

final class AgreementViewController: NavigationViewController {
    
    // MARK: Property
    // TODO: 유즈케이스 리팩 후에 뷰모델 만들어 넘기기
    
    private let nickname: String
    private let lckTeam: String
    private let lckYear: Int
    private let profileImage: UIImage?
    private let defaultImage: String?
    private let profileUseCase = CreateUserProfileUseCase(repository: ProfileRepositoryImpl())
    private let userInformationUseCase = FetchUserInformationUseCase(
        repository: UserSessionRepositoryImpl(
            userDefaults: UserDefaultsStorage(
                jsonEncoder: JSONEncoder(),
                jsonDecoder: JSONDecoder()
            )
        )
    )
    private let cancelBag = CancelBag()
    
    // MARK: - UIComponent
    
    private let rootView = AgreementView()
    
    // MARK: - LifeCycle
    
    init(nickname: String, lckTeam: String, lckYear: Int, profileImage: UIImage? = nil, defaultImage: String? = nil) {
        self.nickname = nickname
        self.lckTeam = lckTeam
        self.lckYear = lckYear
        self.profileImage = profileImage
        self.defaultImage = defaultImage
        
        super.init(type: .flow)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
}

// MARK: - Priviate Extension

private extension AgreementViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        view.addSubview(rootView)
    }
    
    func setupConstraint() {
        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupAction() {
        [
            rootView.personalInfoAgreementItemView.checkButton,
            rootView.privacyPolicyAgreementItemView.checkButton,
            rootView.ageAgreementItemView.checkButton,
            rootView.marketingAgreementItemView.checkButton
        ].forEach {
            $0.addTarget(self, action: #selector(checkButtonDidTap(_:)), for: .touchUpInside)
        }
        rootView.personalInfoAgreementItemView.infoButton.addTarget(
            self,
            action: #selector(infoButtonDidTap(_:)),
            for: .touchUpInside
        )
        rootView.privacyPolicyAgreementItemView.infoButton.addTarget(
            self,
            action: #selector(infoButtonDidTap(_:)),
            for: .touchUpInside
        )
        rootView.allAgreementItemView.checkButton.addTarget(self, action: #selector(allCheckButtonDidTap), for: .touchUpInside)
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - @objc Method
    
    @objc func checkButtonDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        configureNextButton()
    }
    
    @objc func infoButtonDidTap(_ sender: UIButton) {
        guard let url = URL(
            string: sender == rootView.personalInfoAgreementItemView.infoButton ? "https://joyous-ghost-8c7.notion.site/c6e26919055a4ff98fd73a8f9b29cb36?pvs=4" : "https://joyous-ghost-8c7.notion.site/fff08b005ea18052ae0bf9d056c2e830?pvs=4"
        ) else {
            return
        }
        
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .formSheet
        
        self.present(viewController, animated: true)
    }
    
    @objc func allCheckButtonDidTap() {
        rootView.allAgreementItemView.checkButton.isSelected.toggle()
        
        [
            rootView.personalInfoAgreementItemView.checkButton,
            rootView.privacyPolicyAgreementItemView.checkButton,
            rootView.ageAgreementItemView.checkButton,
            rootView.marketingAgreementItemView.checkButton
        ].forEach {
            $0.isSelected = rootView.allAgreementItemView.checkButton.isSelected
        }
        
        configureNextButton()
    }
    
    @objc func nextButtonDidTap() {
        userInformationUseCase.fetchActiveUserInfo()
            .withUnretained(self)
            .sink { owner, userSession in
                guard let userSession = userSession else { return }
                
                owner.profileUseCase.execute(
                    profile: UserProfile(
                        user: User(
                            id: userSession.id,
                            nickname: owner.nickname,
                            profileURL: userSession.profileURL,
                            fanTeam: LCKTeam(rawValue: owner.lckTeam)
                        ),
                        introduction: "",
                        ghostCount: 0,
                        lckYears: owner.lckYear,
                        userLevel: 1
                    ),
                    isPushAlarmAllowed: false,
                    isAlarmAllowed: owner.rootView.marketingAgreementItemView.checkButton.isSelected,
                    image: owner.profileImage,
                    defaultProfileType: owner.defaultImage
                )
                .receive(on: DispatchQueue.main)
                .sink { _ in
                } receiveValue: { [weak self] _ in
                    guard let cancelBag = self?.cancelBag else { return }
                    
                    self?.userInformationUseCase.updateUserSession(
                        session: UserSession(
                            id: userSession.id,
                            nickname: userSession.nickname,
                            profileURL: userSession.profileURL,
                            isPushAlarmAllowed: userSession.isPushAlarmAllowed,
                            isAdmin: userSession.isAdmin,
                            isAutoLoginEnabled: true,
                            // TODO: FCM 구현 이후 바꿔줘야 함
                            notificationBadgeCount: 0
                        )
                    )
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { _ in
                        WableLogger.log("세션 저장 완료", for: .debug)
                    })
                    .store(in: cancelBag)
                    
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let loginViewController = windowScene.windows.first?.rootViewController
                    else {
                        return
                    }
                    
                    let tabBarController = TabBarController()
                    
                    self?.dismiss(animated: false) {
                        guard let nickname = self?.nickname else { return }
                        
                        loginViewController.present(tabBarController, animated: true) {
                            let noticeViewController = WableSheetViewController(
                                title: "와블과 함께해 주셔서 감사합니다!",
                                message: "\(nickname)님\n와블의 일원이 되신 것을 환영해요.\nLCK 함께 보며 같이 즐겨요 :)"
                            )
                            
                            noticeViewController.addAction(.init(title: "와블 즐기러 가기", style: .primary))
                            
                            tabBarController.present(noticeViewController, animated: true)
                        }
                    }
                }
                .store(in: owner.cancelBag)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Function Method
    
    func configureNextButton() {
        let condition = rootView.personalInfoAgreementItemView.checkButton.isSelected
        && rootView.privacyPolicyAgreementItemView.checkButton.isSelected
        && rootView.ageAgreementItemView.checkButton.isSelected
        
        rootView.nextButton.isUserInteractionEnabled = condition
        rootView.nextButton.updateStyle(condition ? .primary : .gray)
    }
}
