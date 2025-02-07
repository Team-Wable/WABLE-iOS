//
//  JoinLCKYearViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import Combine
import SafariServices
import UIKit

import SnapKit

final class JoinLCKYearViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cancelBag = CancelBag()
    private let viewModel: JoinLCKYearViewModel
    
    private lazy var backButtonTapped = self.navigationBackButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var nextButtonTapped = self.originView.nextButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private var navigationXButton = XButton()
    private let originView = JoinLCKYearView()
    
    // MARK: - Life Cycles
    
    init(viewModel: JoinLCKYearViewModel) {
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

// MARK: - Private Method

extension JoinLCKYearViewController {
    func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton, navigationXButton)
    }
    
    func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        
        navigationXButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12.adjusted)
        }
    }
    
    func setAddTarget() {
        navigationXButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
    }
    
    func bindViewModel() {
        let input = JoinLCKYearViewModel.Input(
            backButtonTapped: backButtonTapped,
            nextButtonTapped: nextButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let viewController = JoinLCKTeamViewController(viewModel: JoinLCKTeamViewModel())
                    viewController.memberLckYears = Int(self.originView.selectedStartYear.text ?? "2024")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .store(in: self.cancelBag)
    }
    
    @objc
    func xButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = [LoginViewController(viewModel: MigratedLoginViewModel())]
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
}
