//
//  MyPageSignOutViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import UIKit

class MyPageSignOutViewController: UIViewController {

    // MARK: - Properties
    
    private var cancelBag = CancelBag()
    private let myPageSignOutReasonViewModel: MyPageSignOutReasonViewModel
    
    private lazy var firstReason = self.myView.firstReasonView.radioButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var secondReason = self.myView.secondReasonView.radioButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var thirdReason = self.myView.thirdReasonView.radioButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var fourthReason = self.myView.fourthReasonView.radioButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var fifthReason = self.myView.fifthReasonView.radioButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var sixthReason = self.myView.sixthReasonView.radioButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var seventhReason = self.myView.seventhReasonView.radioButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var continueButtonTapped = self.myView.continueButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    var signOutReason: [String] = []
    
    // MARK: - UI Components
    
    private let myView = MyPageSignOutView()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = myView
    }
    
    init(viewModel: MyPageSignOutReasonViewModel) {
        self.myPageSignOutReasonViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        setAddTarget()
        setNavigationBar()
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

extension MyPageSignOutViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {
        
    }
    
    private func setAddTarget() {
        
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        self.title = "계정 삭제"
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc
    private func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func bindViewModel() {
        let input = MyPageSignOutReasonViewModel.Input(
            firstReasonButtonTapped: firstReason,
            secondReasonButtonTapped: secondReason,
            thirdReasonButtonTapped: thirdReason,
            fourthReasonButtonTapped: fourthReason,
            fifthReasonButtonTapped: fifthReason,
            sixthReasonButtonTapped: sixthReason,
            seventhReasonButtonTapped: seventhReason,
            continueButtonTapped: continueButtonTapped)
        
        let output = myPageSignOutReasonViewModel.transform(from: input, cancelBag: cancelBag)
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else if value == 1 {
                    let vc = MyPageSignOutConfirmViewController(viewModel: MyPageSignOutConfirmViewModel(networkProvider: NetworkService()))
                    vc.signOutReason = self.signOutReason
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .store(in: self.cancelBag)
        
        output.clickedButtonState
            .sink { [weak self] index, isClicked in
                guard let self = self else { return }
                let checkImage = isClicked ? ImageLiterals.Button.btnCheckboxActive : ImageLiterals.Button.btnCheckboxDefault
                
                self.myView.continueButton.isEnabled = true
                
                switch index {
                case 1:
                    self.myView.firstReasonView.radioButton.setImage(checkImage, for: .normal)
                    appendSignOutReasons(title: self.myView.firstReasonView.radioButton.currentTitle ?? "")
                case 2:
                    self.myView.secondReasonView.radioButton.setImage(checkImage, for: .normal)
                    appendSignOutReasons(title: self.myView.secondReasonView.radioButton.currentTitle ?? "")
                case 3:
                    self.myView.thirdReasonView.radioButton.setImage(checkImage, for: .normal)
                    appendSignOutReasons(title: self.myView.thirdReasonView.radioButton.currentTitle ?? "")
                case 4:
                    self.myView.fourthReasonView.radioButton.setImage(checkImage, for: .normal)
                    appendSignOutReasons(title: self.myView.fourthReasonView.radioButton.currentTitle ?? "")
                case 5:
                    self.myView.fifthReasonView.radioButton.setImage(checkImage, for: .normal)
                    appendSignOutReasons(title: self.myView.fifthReasonView.radioButton.currentTitle ?? "")
                case 6:
                    self.myView.sixthReasonView.radioButton.setImage(checkImage, for: .normal)
                    appendSignOutReasons(title: self.myView.sixthReasonView.radioButton.currentTitle ?? "")
                case 7:
                    self.myView.seventhReasonView.radioButton.setImage(checkImage, for: .normal)
                    appendSignOutReasons(title: self.myView.seventhReasonView.radioButton.currentTitle ?? "")
                default:
                    break
                }
            }
            .store(in: self.cancelBag)
        
        output.isEnable
            .sink { value in
                if value == true {
                    self.myView.continueButton.isEnabled = true
                } else {
                    self.myView.continueButton.isEnabled = false
                }
            }
            .store(in: self.cancelBag)
    }
    
    func appendSignOutReasons(title: String) {
        if let index = signOutReason.firstIndex(of: title) {
            signOutReason.remove(at: index)
        } else {
            signOutReason.append(title)
        }
    }
}
