//
//  WableActionSheetViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/14/25.
//

import UIKit

import SnapKit
import Then

typealias CompletionHandler = (_ completion: @escaping (Bool) -> Void) -> Void

// MARK: - WableActionSheetConfiguration

struct WableActionSheetConfiguration {
    let title: String
    let message: String?
    let confirmButtonTitle: String
    let cancelButtonTitle: String?
    let confirmAction: CompletionHandler?
    let cancelAction: CompletionHandler?
    
    init(
        title: String,
        message: String? = nil,
        confirmButtonTitle: String,
        cancelButtonTitle: String? = nil,
        confirmAction: CompletionHandler? = nil,
        cancelAction: CompletionHandler? = nil
    ) {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
    }
}

// MARK: - WableActionSheetViewController

final class WableActionSheetViewController: UIViewController {
    
    // MARK: - UIComponent
    
    private let containerView = UIView().then {
        $0.backgroundColor = .wableWhite
        $0.layer.cornerRadius = 16
    }
    
    private let labelStackView = UIStackView(axis: .vertical).then {
        $0.spacing = 8
        $0.distribution = .fill
        $0.alignment = .center
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.attributedText = configuration.title.pretendardString(with: .head1)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private lazy var messageLabel = UILabel().then {
        $0.attributedText = configuration.message?.pretendardString(with: .body2)
        $0.textColor = .gray700
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let buttonStackView = UIStackView(axis: .horizontal).then {
        $0.spacing = 8
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    private lazy var confirmButton = WableButton(style: .primary).then {
        var config = $0.configuration ?? .filled()
        config.attributedTitle = configuration.confirmButtonTitle.pretendardString(with: .body1)
        $0.configuration = config
    }
    
    private lazy var cancelButton = WableButton(style: .gray).then {
        var config = $0.configuration ?? .filled()
        config.attributedTitle = configuration.cancelButtonTitle?.pretendardString(with: .body1)
        $0.configuration = config
    }
    
    // MARK: - Property
    
    private let configuration: WableActionSheetConfiguration
    
    // MARK: - Initializer
    
    init(configuraton: WableActionSheetConfiguration) {
        self.configuration = configuraton
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
}

// MARK: - Setup Method

private extension WableActionSheetViewController {
    func setupView() {
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        
        view.addSubview(containerView)
        
        containerView.addSubviews(
            labelStackView,
            buttonStackView
        )
        
        labelStackView.addArrangedSubview(titleLabel)
        if let message = configuration.message,
           !message.isEmpty {
            labelStackView.addArrangedSubview(messageLabel)
        }
        
        if let cancelButtonTitle = configuration.cancelButtonTitle,
           !cancelButtonTitle.isEmpty {
            buttonStackView.addArrangedSubview(cancelButton)
        }
        buttonStackView.addArrangedSubview(confirmButton)
    }
    
    func setupConstraint() {
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(labelStackView.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.adjustedHeightEqualTo(48)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setupAction() {
        confirmButton.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - objc Method

private extension WableActionSheetViewController {
    @objc func confirmButtonDidTap() {
        guard let action = configuration.confirmAction else {
            dismiss(animated: true)
            return
        }
        
        action { [weak self] isCompleted in
            guard isCompleted else { return }
            self?.dismiss(animated: true)
        }
    }
    
    @objc func cancelButtonDidTap() {
        guard let action = configuration.cancelAction else {
            dismiss(animated: true)
            return
        }
        
        action { [weak self] isCompleted in
            guard isCompleted else { return }
            self?.dismiss(animated: true)
        }
    }
}
