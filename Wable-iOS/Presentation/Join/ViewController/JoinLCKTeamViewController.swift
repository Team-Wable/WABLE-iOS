//
//  JoinLCKTeamViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import Combine
import UIKit

import SnapKit

final class JoinLCKTeamViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cancelBag = CancelBag()
    private let viewModel: JoinLCKTeamViewModel
    
    private lazy var backButtonTapped = self.navigationBackButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var noLCKTeamButtonTapped = self.originView.noLCKTeamButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var nextButtonTapped = self.originView.nextButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    var memberLckYears: Int?
    var memberFanTeam: String?
    var memberDefaultProfileImage: String?
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private var navigationXButton = XButton()
    private let originView = JoinLCKTeamView()
    
    // MARK: - Life Cycles
    
    init(viewModel: JoinLCKTeamViewModel) {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
}

// MARK: - Extensions

extension JoinLCKTeamViewController {
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
        navigationXButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        let input = JoinLCKTeamViewModel.Input(
            backButtonTapped: backButtonTapped,
            noLCKTeamButtonTapped: noLCKTeamButtonTapped,
            nextButtonTapped: nextButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else if value == 2 {
                    // LCK 팀 고르지 않은 경우
                    let viewController = JoinProfileViewController(viewModel: JoinProfileViewModel(networkProvider: NetworkService()))
                    viewController.memberLckYears = self.memberLckYears
                    viewController.memberFanTeam = "LCK"
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    // LCK 팀을 고른 경우
                    let viewController = JoinProfileViewController(viewModel: JoinProfileViewModel(networkProvider: NetworkService()))
                    viewController.memberLckYears = self.memberLckYears
                    viewController.memberFanTeam = self.originView.selectedButton?.titleLabel?.text
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .store(in: self.cancelBag)
    }
    
    @objc private func xButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = [LoginViewController(viewModel: MigratedLoginViewModel())]
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
}
