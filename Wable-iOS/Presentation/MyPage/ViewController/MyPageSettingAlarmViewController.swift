//
//  MyPageSettingAlarmViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/20/24.
//

import UIKit

final class MyPageSettingAlarmViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - UI Components
    
    private let topDivisionLine = UIView().makeDivisionLine()
    
    private let pushAlarmSettingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let pushAlarmTitle: UILabel = {
        let label = UILabel()
        label.text = "푸시 알림"
        label.font = .body2
        label.textColor = .gray600
        return label
    }()
    
    private let pushAlarmSettingLabel: UILabel = {
        let label = UILabel()
        label.font = .body1
        label.textColor = .wableBlack
        return label
    }()
    
    private let pushAlarmSettingButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnNext, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
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
        setAddTarget()
        
        // 앱이 다시 활성화될 때 알림 설정 상태를 확인하도록 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: - Extensions

extension MyPageSettingAlarmViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        
        isNotificationEnabled { isEnabled in
            if isEnabled {
                self.pushAlarmSettingLabel.text = "on"
            } else {
                self.pushAlarmSettingLabel.text = "off"
            }
        }
    }
    
    private func setHierarchy() {
        self.view.addSubviews(topDivisionLine, pushAlarmSettingView)
        
        pushAlarmSettingView.addSubviews(pushAlarmTitle,
                                         pushAlarmSettingLabel,
                                         pushAlarmSettingButton)
    }
    
    private func setLayout() {
        topDivisionLine.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
        }
        
        pushAlarmSettingView.snp.makeConstraints {
            $0.top.equalTo(topDivisionLine.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(52.adjusted)
        }
        
        pushAlarmTitle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(26.adjusted)
        }
        
        pushAlarmSettingLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(pushAlarmSettingButton.snp.leading)
        }
        
        pushAlarmSettingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.size.equalTo(48)
        }
    }
    
    private func setAddTarget() {
        pushAlarmSettingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushAlarmSettingButtonTapped)))
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        self.title = "알림 설정"
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc
    private func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // 알림 설정을 확인하는 함수
    @objc
    private func isNotificationEnabled(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    @objc
    private func pushAlarmSettingButtonTapped() {
        if let alarmSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(alarmSettings) {
                UIApplication.shared.open(alarmSettings, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc
    private func appDidBecomeActive() {
        // 앱이 다시 활성화될 때 알림 상태 확인 및 UI 업데이트
        isNotificationEnabled { isEnabled in
            if isEnabled {
                self.pushAlarmSettingLabel.text = "on"
            } else {
                self.pushAlarmSettingLabel.text = "off"
            }
        }
    }
}
