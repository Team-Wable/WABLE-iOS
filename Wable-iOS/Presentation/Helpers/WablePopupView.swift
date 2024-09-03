//
//  WablePopupView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/18/24.
//

import UIKit

import SnapKit

protocol WablePopupDelegate: AnyObject {
    func cancleButtonTapped()
    func confirmButtonTapped()
}

final class WablePopupView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: WablePopupDelegate?
    
    // MARK: - UI Components
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .wableWhite
        view.layer.cornerRadius = 16.adjusted
        return view
    }()
    
    private let popupTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .wableBlack
        label.textAlignment = .center
        label.font = .head2
        label.numberOfLines = 0
        return label
    }()
    
    private let popupContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray700
        label.textAlignment = .center
        label.font = .body2
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 7.adjusted
        return stackView
    }()
    
    private let cancleButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.gray600, for: .normal)
        button.titleLabel?.font = .body1
        button.backgroundColor = .gray200
        button.layer.cornerRadius = 12.adjusted
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.wableWhite, for: .normal)
        button.titleLabel?.font = .body1
        button.backgroundColor = .purple50
        button.layer.cornerRadius = 12.adjusted
        return button
    }()
    
    // MARK: - Life Cycles
    
    init(popupTitle: String, popupContent: String, leftButtonTitle: String, rightButtonTitle: String) {
        super.init(frame: .zero)
        
        popupTitleLabel.text = popupTitle // 팝업 타이틀
        popupContentLabel.text = popupContent // 팝업 내용
        cancleButton.setTitle(leftButtonTitle, for: .normal) // 팝업 왼쪽 버튼 타이틀
        confirmButton.setTitle(rightButtonTitle, for: .normal) // 팝업 오른쪽 버튼 타이틀
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension WablePopupView {
    func setUI() {
        self.backgroundColor = .wableBlack.withAlphaComponent(0.5)
    }
    
    func setHierarchy() {
        self.addSubview(container)
        
        // 팝업뷰 내용이 없는 경우
        if popupContentLabel.text == "" {
            container.addSubviews(popupTitleLabel, buttonStackView)
        } else {
            container.addSubviews(popupTitleLabel, popupContentLabel, buttonStackView)
        }
        
        buttonStackView.addArrangedSubview(cancleButton)
        buttonStackView.addArrangedSubview(confirmButton)
    }
    
    func setLayout() {
        container.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(30.adjusted)
            $0.centerY.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(18.adjusted)
            $0.height.equalTo(48.adjusted)
        }
        
        // 팝업뷰 내용이 없는 경우
        if popupContentLabel.text == "" {
            popupTitleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().inset(32.adjusted)
                $0.leading.trailing.equalToSuperview().inset(24.adjusted)
                $0.bottom.equalTo(cancleButton.snp.top).offset(-32.adjusted)
            }
            
            buttonStackView.snp.makeConstraints {
                $0.leading.trailing.bottom.equalToSuperview().inset(18.adjusted)
                $0.height.equalTo(48.adjusted)
            }
        } else {
            popupTitleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().inset(32.adjusted)
                $0.leading.trailing.equalToSuperview().inset(24.adjusted)
                $0.bottom.equalTo(popupContentLabel.snp.top).offset(-8.adjusted)
            }
            
            popupContentLabel.snp.makeConstraints {
                $0.top.equalTo(popupTitleLabel.snp.bottom).offset(8.adjusted)
                $0.leading.trailing.equalToSuperview().inset(24.adjusted)
                $0.bottom.equalTo(cancleButton.snp.top).offset(-32.adjusted)
            }
        }
    }
    
    func setAddTarget() {
        self.cancleButton.addTarget(self, action: #selector(cancleButtonTapped), for: .touchUpInside)
        self.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func cancleButtonTapped() {
        delegate?.cancleButtonTapped()
    }
    
    @objc
    func confirmButtonTapped() {
        delegate?.confirmButtonTapped()
    }
}
