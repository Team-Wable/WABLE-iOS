//
//  WableTextSheetViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 6/22/25.
//

import UIKit

import SnapKit
import Then

// MARK: - WableTextSheetAction

struct WableTextSheetAction {
    enum Style {
        case primary
        case gray
    }
    
    let title: String
    let style: Style
    let handler: ((String?) -> Void)?
    
    init(
        title: String,
        style: Style,
        handler: ((String?) -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

fileprivate extension WableTextSheetAction.Style {
    var buttonStyle: WableButton.Style {
        switch self {
        case .primary:
            return .primary
        case .gray:
            return .gray
        }
    }
}

// MARK: - WableTextSheetViewController

final class WableTextSheetViewController: UIViewController {
    
    // MARK: - UIComponent
    
    private let containerView = UIView(backgroundColor: .wableWhite).then {
        $0.layer.cornerRadius = 16
    }
    
    private let titleLabel = UILabel().then {
        $0.attributedText = "제목".pretendardString(with: .head1)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let messageTextView = UITextView(backgroundColor: .gray100).then {
        $0.font = .pretendard(.body4)
        $0.textColor = .wableBlack
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        $0.layer.cornerRadius = 12
    }
    
    private let placeholderLabel = UILabel().then {
        $0.attributedText = "플레이스홀더".pretendardString(with: .body4)
        $0.textColor = .gray600
        $0.numberOfLines = 0
    }
    
    private let textCountLabel = UILabel().then {
        $0.attributedText = "0/100".pretendardString(with: .caption4)
        $0.textAlignment = .right
    }
    
    private let buttonStackView = UIStackView(axis: .horizontal).then {
        $0.spacing = 8
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    // MARK: - Property

    private let sheetTitle: String
    private let placeholder: String
    
    // MARK: - Life Cycle

    init(title: String, placeholder: String) {
        self.sheetTitle = title
        self.placeholder = placeholder
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
    }
}

extension WableTextSheetViewController {
    func addAction(_ action: WableTextSheetAction) {
        let button = createWableButton(for: action)
        buttonStackView.addArrangedSubview(button)
    }
    
    func addActions(_ actions: WableTextSheetAction...) {
        actions.forEach { addAction($0) }
    }
    
    private func createWableButton(for action: WableTextSheetAction) -> WableButton {
        return WableButton(style: action.style.buttonStyle).then {
            var config = $0.configuration ?? .filled()
            config.attributedTitle = action.title.pretendardString(with: .body1)
            $0.configuration = config
            
            let action = UIAction { [weak self] _ in
                self?.dismiss(animated: true) {
                    action.handler?(self?.messageTextView.text)
                }
            }
            
            $0.addAction(action, for: .touchUpInside)
        }
    }
}

private extension WableTextSheetViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        
        titleLabel.text = sheetTitle
        placeholderLabel.text = placeholder
        
        view.addSubview(containerView)
        
        messageTextView.addSubview(placeholderLabel)
        
        containerView.addSubviews(
            titleLabel,
            messageTextView,
            textCountLabel,
            buttonStackView
        )
    }
    
    func setupConstraint() {
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        messageTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(titleLabel)
            make.adjustedHeightEqualTo(156)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        textCountLabel.snp.makeConstraints { make in
            make.top.equalTo(messageTextView.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(messageTextView)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(textCountLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(textCountLabel)
            make.adjustedHeightEqualTo(48)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
