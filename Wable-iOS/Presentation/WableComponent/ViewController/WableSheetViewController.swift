//
//  WableSheetViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/14/25.
//

import UIKit

import SnapKit
import Then

// MARK: - WableSheetAction

struct WableSheetAction {
    enum Style {
        case primary
        case gray
    }
    
    let title: String
    let style: Style
    let handler: (() -> Void)?
    
    init(
        title: String,
        style: Style,
        handler: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

fileprivate extension WableSheetAction.Style {
    var buttonStyle: WableButton.Style {
        switch self {
        case .primary:
            return .primary
        case .gray:
            return .gray
        }
    }
}

// MARK: - WableSheetViewController

final class WableSheetViewController: UIViewController {
    
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
        $0.attributedText = self.sheetTitle.pretendardString(with: .head2)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private lazy var messageLabel = UILabel().then {
        $0.attributedText = self.message?.pretendardString(with: .body2)
        $0.textColor = .gray700
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let buttonStackView = UIStackView(axis: .horizontal).then {
        $0.spacing = 8
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    // MARK: - Property
    
    private let sheetTitle: String
    private let message: String?
    
    // MARK: - Initializer
    
    init(title: String, message: String? = nil) {
        self.sheetTitle = title
        self.message = message
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
    }
}

extension WableSheetViewController {
    func addAction(_ action: WableSheetAction) {
        let button = createWableButton(for: action)
        buttonStackView.addArrangedSubview(button)
    }
    
    func addActions(_ actions: WableSheetAction...) {
        actions.forEach { addAction($0) }
    }
    
    private func createWableButton(for action: WableSheetAction) -> WableButton {
        return WableButton(style: action.style.buttonStyle).then {
            var config = $0.configuration ?? .filled()
            config.attributedTitle = action.title.pretendardString(with: .body1)
            $0.configuration = config
            
            let action = UIAction { [weak self] _ in
                self?.dismiss(animated: true) {
                    action.handler?()
                }
            }
            
            $0.addAction(action, for: .touchUpInside)
        }
    }
}

private extension WableSheetViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        
        view.addSubview(containerView)
        
        containerView.addSubviews(
            labelStackView,
            buttonStackView
        )
        
        labelStackView.addArrangedSubview(titleLabel)
        if let message,
           !message.isEmpty {
            labelStackView.addArrangedSubview(messageLabel)
        }
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
}
