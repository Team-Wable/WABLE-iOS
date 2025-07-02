//
//  AgreementItemView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/21/25.
//


import UIKit

final class AgreementItemView: UIView {
    
    // MARK: - UIComponent
    
    lazy var checkButton: UIButton = UIButton().then {
        $0.setImage(.btnCheckboxDefault, for: .normal)
        $0.setImage(.btnCheckboxActive, for: .selected)
    }
    
    let titleLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
        $0.font = .pretendard(.body2)
    }
    
    lazy var infoButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.attributedTitle = "보러가기".pretendardString(with: .body4).addUnderline()
        $0.configuration?.baseForegroundColor = .gray500
        $0.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
    
    // MARK: - LifeCycle
    
    init(title: String, hasInformation: Bool) {
        super.init(frame: .zero)
        
        setupView(title: title, hasInformation: hasInformation)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension

private extension AgreementItemView {
    
    // MARK: - Setup Method
    
    func setupView(title: String, hasInformation: Bool) {
        addSubviews(
            checkButton,
            titleLabel,
            infoButton
        )
        
        titleLabel.text = title
        infoButton.isHidden = !hasInformation
    }
    
    func setupConstraint() {
        snp.makeConstraints {
            $0.adjustedHeightEqualTo(48)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(4)
            $0.centerY.equalTo(checkButton)
        }
        
        checkButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(48)
            $0.centerY.equalTo(titleLabel)
        }
        
        infoButton.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(6)
            $0.centerY.equalTo(titleLabel)
        }
    }
}
