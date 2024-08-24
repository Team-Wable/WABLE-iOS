//
//  JoinAgreementViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import Combine
import SafariServices
import UIKit

import SnapKit

final class JoinAgreementViewController: UIViewController {
    
    // MARK: - Properties
    
    let useAgreementURL = URL(string: "https://www.notion.so/93625ba2f93547ff88984d3bb82a2f32")
    let privacyURL = URL(string: "https://www.notion.so/1681f9cae9de47858ee0997b4cea9c03")
    let advertisementURL = URL(string: "https://www.notion.so/0c70bf474acb487ab2b2ae957d975e51")
    
    var memberNickname: String?
    var memberLckYears: Int?
    var memberFanTeam: String?
    var memberDefaultProfileImage: String?
    var memberProfileImage: UIImage?
    
    private var cancelBag = CancelBag()
    private let viewModel: JoinAgreementViewModel
    
    private lazy var backButtonTapped = self.navigationBackButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var xButtonTapped = self.navigationXButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var allCheckButtonTapped = self.originView.allCheck.checkButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var firstCheck = self.originView.firstCheckView.checkButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var secondCheck = self.originView.secondCheckView.checkButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var thirdCheck = self.originView.thirdCheckView.checkButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var fourtchCheck = self.originView.fourthCheckView.checkButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var nextButtonTapped = self.originView.JoinCompleteActiveButton.publisher(for: .touchUpInside).map { _ in
        return UserProfileUnionRequestDTO(
            info: UserProfileRequestDTO(
                nickname: self.memberNickname,
                isAlarmAllowed: (self.originView.fourthCheckView.checkButton.currentImage == ImageLiterals.Button.btnCheckboxActive) ? true : false ,
                memberIntro: "",
                isPushAlarmAllowed: true,
                fcmToken: "",
                memberLckYears: self.memberLckYears,
                memberFanTeam: self.memberFanTeam,
                memberDefaultProfileImage: self.memberDefaultProfileImage),
            file: self.memberProfileImage?.jpegData(compressionQuality: 0.8)!
        )
    }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private var navigationXButton = XButton()
    private let originView = JoinAgreementView()
    
    // MARK: - Life Cycles
    
    init(viewModel: JoinAgreementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = originView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }
}

// MARK: - Extensions

extension JoinAgreementViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    private func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton, navigationXButton)
    }
    
    private func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        
        navigationXButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12.adjusted)
        }
    }
    
    private func setAddTarget() {
        self.originView.firstCheckView.moreButton.addTarget(self, action: #selector(firstMoreButtonTapped), for: .touchUpInside)
        self.originView.secondCheckView.moreButton.addTarget(self, action: #selector(secondMoreButtonTapped), for: .touchUpInside)
        self.originView.fourthCheckView.moreButton.addTarget(self, action: #selector(fourthMoreButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        let input = JoinAgreementViewModel.Input(
            backButtonTapped: backButtonTapped,
            allCheckButtonTapped: allCheckButtonTapped,
            firstCheckButtonTapped: firstCheck,
            secondCheckButtonTapped: secondCheck,
            thirdCheckButtonTapped: thirdCheck,
            fourthCheckButtonTapped: fourtchCheck,
            nextButtonTapped: nextButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        
        let allCheckButton = self.originView.allCheck.checkButton
        let checkButtons = [
            self.originView.firstCheckView.checkButton,
            self.originView.secondCheckView.checkButton,
            self.originView.thirdCheckView.checkButton,
            self.originView.fourthCheckView.checkButton
        ]
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let viewController = WableTabBarController()
                    self.navigationBackButton.removeFromSuperview()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .store(in: self.cancelBag)
        
        output.clickedButtonState
            .sink { [weak self] index, isClicked in
                guard let self = self else { return }
                let checkImage = isClicked ? ImageLiterals.Button.btnCheckboxActive : ImageLiterals.Button.btnCheckboxDefault
                
                switch index {
                case 1:
                    // 첫 번째 버튼 UI 업데이트
                    self.originView.firstCheckView.checkButton.setImage(checkImage, for: .normal)
                case 2:
                    // 두 번째 버튼 UI 업데이트
                    self.originView.secondCheckView.checkButton.setImage(checkImage, for: .normal)
                case 3:
                    // 세 번째 버튼 UI 업데이트
                    self.originView.thirdCheckView.checkButton.setImage(checkImage, for: .normal)
                case 4:
                    // 네 번째 버튼 UI 업데이트
                    self.originView.fourthCheckView.checkButton.setImage(checkImage, for: .normal)
                default:
                    break
                }
            }
            .store(in: self.cancelBag)
        
        output.isAllcheck
            .sink { isNextButtonEnabled in
                let checkImage = isNextButtonEnabled ? ImageLiterals.Button.btnCheckboxActive : ImageLiterals.Button.btnCheckboxDefault
                allCheckButton.setImage(checkImage, for: .normal)
                
                checkButtons.forEach { button in
                    button.setImage(checkImage, for: .normal)
                }
            }
            .store(in: self.cancelBag)
        
        output.isEnable
            .sink { value in
                if value == 0 {
                    self.originView.JoinCompleteActiveButton.isHidden = false
                    self.originView.allCheck.checkButton.setImage(ImageLiterals.Button.btnCheckboxActive, for: .normal)
                } else if value == 1 {
                    self.originView.JoinCompleteActiveButton.isHidden = false
                    self.originView.allCheck.checkButton.setImage(ImageLiterals.Button.btnCheckboxDefault, for: .normal)
                } else {
                    self.originView.JoinCompleteActiveButton.isHidden = true
                    self.originView.allCheck.checkButton.setImage(ImageLiterals.Button.btnCheckboxDefault, for: .normal)
                }
            }
            .store(in: self.cancelBag)
    }
    
    @objc
    private func firstMoreButtonTapped() {
        let useAgreementView: SFSafariViewController
        if let useAgreementURL = self.useAgreementURL {
            useAgreementView = SFSafariViewController(url: useAgreementURL)
            self.present(useAgreementView, animated: true, completion: nil)
        } else {
            print("👻👻👻 유효하지 않은 URL 입니다 👻👻👻")
        }
    }
    
    @objc
    private func secondMoreButtonTapped() {
        let useAgreementView: SFSafariViewController
        if let useAgreementURL = self.privacyURL {
            useAgreementView = SFSafariViewController(url: useAgreementURL)
            self.present(useAgreementView, animated: true, completion: nil)
        } else {
            print("👻👻👻 유효하지 않은 URL 입니다 👻👻👻")
        }
    }
    
    @objc
    private func fourthMoreButtonTapped() {
        let useAgreementView: SFSafariViewController
        if let useAgreementURL = self.advertisementURL {
            useAgreementView = SFSafariViewController(url: useAgreementURL)
            self.present(useAgreementView, animated: true, completion: nil)
        } else {
            print("👻👻👻 유효하지 않은 URL 입니다 👻👻👻")
        }
    }
}
