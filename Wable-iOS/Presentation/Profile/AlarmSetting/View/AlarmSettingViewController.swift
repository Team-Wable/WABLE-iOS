//
//  AlarmSettingViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/13/25.
//

import Combine
import UIKit

import SnapKit
import Then

final class AlarmSettingViewController: UIViewController {

    // MARK: - UIComponent

    private let navigationView = NavigationView(type: .page(type: .detail, title: "알림 설정"))
    
    private let titleLabel = UILabel().then {
        $0.attributedText = "푸시 알림".pretendardString(with: .body2)
        $0.textColor = .gray600
    }
    
    private let statusLabel = UILabel().then {
        $0.attributedText = "off".pretendardString(with: .body1)
    }
    
    private let openSettingbutton = UIButton().then {
        $0.setImage(.btnNext.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    // MARK: - Property

    private let viewModel: AlarmSettingViewModel
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer

    init(viewModel: AlarmSettingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        setupAction()
        setupBinding()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        viewModel.checkAlarmAuthorization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

private extension AlarmSettingViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(navigationView, titleLabel, statusLabel, openSettingbutton)
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(openSettingbutton.snp.leading)
        }
        
        openSettingbutton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(48)
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupAction() {
        navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        openSettingbutton.addTarget(self, action: #selector(openSettingButtonDidTap), for: .touchUpInside)
    }
    
    func setupBinding() {
        viewModel.$isAuthorized
            .map { $0 ? "on" : "off" }
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: statusLabel)
            .store(in: cancelBag)
    }
    
    // MARK: - Action Method

    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func openSettingButtonDidTap() {
        let urlString: String
        if #available(iOS 16.0, *) {
            urlString = UIApplication.openNotificationSettingsURLString
        } else {
            urlString = UIApplication.openSettingsURLString
        }
        
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url)
        else {
            return WableLogger.log("설정 창 열 수 없음!", for: .debug)
        }
        
        UIApplication.shared.open(url)
    }
    
    @objc func appDidBecomActive() {
        viewModel.checkAlarmAuthorization()
    }
}
