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
    private let updateFCMTokenUseCase = UpdateFCMTokenUseCase(repository: ProfileRepositoryImpl())
    private let profileUseCase = UserProfileUseCase(repository: ProfileRepositoryImpl())
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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
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
        
        if sender.isSelected == false {
            rootView.allAgreementItemView.checkButton.isSelected = false
        }
        
        checkAllAgreeCondition()
        configureNextButton()
    }
    
    @objc func infoButtonDidTap(_ sender: UIButton) {
        guard let url = URL(
            string: sender == rootView.personalInfoAgreementItemView.infoButton ? StringLiterals.URL.terms : StringLiterals.URL.privacyPolicy
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
        AmplitudeManager.shared.trackEvent(tag: .clickCompleteTncSignup)
        
        userInformationUseCase.fetchActiveUserInfo()
            .withUnretained(self)
            .sink {
                owner,
                userSession in
                guard let userSession = userSession else { return }
                
                owner.profileUseCase.updateProfile(
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
                    isPushAlarmAllowed: owner.rootView.marketingAgreementItemView.checkButton.isSelected,
                    isAlarmAllowed: owner.rootView.marketingAgreementItemView.checkButton.isSelected,
                    image: owner.profileImage,
                    defaultProfileType: owner.defaultImage
                )
                .receive(on: DispatchQueue.main)
                .sink { _ in
                } receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.updateFCMTokenUseCase.execute(nickname: owner.nickname)
                        .sink { completion in
                            if case .failure(let error) = completion {
                                WableLogger.log("FCM 토큰 저장 중 에러 발생: \(error)", for: .error)
                            }
                        } receiveValue: { () in
                        }
                        .store(in: cancelBag)
                    
                    self.userInformationUseCase.updateUserSession(
                        userID: userSession.id,
                        nickname: userSession.nickname,
                        profileURL: userSession.profileURL,
                        isPushAlarmAllowed: userSession.isPushAlarmAllowed,
                        isAdmin: userSession.isAdmin,
                        isAutoLoginEnabled: true,
                        notificationBadgeCount: userSession.notificationBadgeCount
                    )
                    .sink(
                        receiveCompletion: { _ in
                        },
                        receiveValue: { _ in
                            WableLogger.log("세션 저장 완료", for: .debug)
                            
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let loginViewController = windowScene.windows.first?.rootViewController
                            else {
                                return
                            }
                            
                            let tabBarController = TabBarController()
                            
                            self.dismiss(animated: false) {
                                loginViewController.present(tabBarController, animated: true) {
                                    let noticeViewController = WableSheetViewController(
                                        title: StringLiterals.Onboarding.completeSheetTitle,
                                        message: "\(self.nickname)님\n와블의 일원이 되신 것을 환영해요.\nLCK 함께 보며 같이 즐겨요 :)"
                                    )
                                    
                                    noticeViewController.addAction(
                                        .init(
                                            title: StringLiterals.Onboarding.completeButtonTitle,
                                            style: .primary,
                                            handler: {
                                                AmplitudeManager.shared.trackEvent(tag: .clickJoinPopupSignup)
                                            })
                                    )
                                    
                                    tabBarController.present(noticeViewController, animated: true)
                                }
                            }
                        })
                    .store(in: cancelBag)
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
    
    func checkAllAgreeCondition() {
        rootView.allAgreementItemView.checkButton.isSelected =
        rootView.personalInfoAgreementItemView.checkButton.isSelected &&
        rootView.privacyPolicyAgreementItemView.checkButton.isSelected &&
        rootView.ageAgreementItemView.checkButton.isSelected &&
        rootView.marketingAgreementItemView.checkButton.isSelected
    }
}
