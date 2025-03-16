//
//  NotFoundViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/13/25.
//

import UIKit

import SnapKit
import Then

final class NotFoundViewController: UIViewController {
    
    // MARK: - UIComponent
    
    private let notFoundImageView = UIImageView().then {
        $0.image = .imgError
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.attributedText = "이런!".pretendardString(with: .head0)
        $0.textAlignment = .center
        $0.textColor = .wableBlack
    }
    
    private let subtitleLabel = UILabel().then {
        $0.attributedText = "현재 요청하신 페이지를 찾을 수 없어요!".pretendardString(with: .head2)
        $0.textAlignment = .center
        $0.textColor = .wableBlack
    }
    
    private let backToHomeButton = WableButton(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = "홈으로 가기".pretendardString(with: .body1)
        $0.configuration = config
    }
    
    // MARK: - Property

    private let backToHomeAction: () -> Void
    
    // MARK: - Initializer

    init(backToHomeAction: @escaping () -> Void) {
        self.backToHomeAction = backToHomeAction
        
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

private extension NotFoundViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            notFoundImageView,
            titleLabel,
            subtitleLabel,
            backToHomeButton
        )
    }
    
    func setupConstraint() {
        notFoundImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(196)
            make.centerX.equalToSuperview()
            make.adjustedWidthEqualTo(220)
            make.height.equalTo(notFoundImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(notFoundImageView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        backToHomeButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(44)
            make.horizontalEdges.equalToSuperview().inset(48)
            make.height.equalTo(backToHomeButton.snp.width).multipliedBy(48.0/280.0)
        }
    }
    
    func setupAction() {
        let dismissAction = UIAction { [weak self] _ in
            self?.backToHomeAction()
            self?.dismiss(animated: true)
        }
        
        backToHomeButton.addAction(dismissAction, for: .touchUpInside)
    }
}
