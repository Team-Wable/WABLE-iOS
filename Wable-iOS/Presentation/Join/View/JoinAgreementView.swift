//
//  JoinAgreementView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

import SnapKit

final class JoinAgreementView: UIView {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = StringLiterals.Join.JoinAgreementTitle
        title.textColor = .wableBlack
        title.numberOfLines = 2
        title.font = .head0
        title.setTextWithLineHeight(text: title.text, lineHeight: 37.adjusted, alignment: .left)
        return title
    }()
    
    let allCheck = JoinAgreementListCustomView(title: StringLiterals.Join.JoinAgreementAllCheck, isMoreButton: false)
    let firstCheckView = JoinAgreementListCustomView(title: StringLiterals.Join.useAgreement, isMoreButton: true)
    let secondCheckView = JoinAgreementListCustomView(title: StringLiterals.Join.privacyAgreement, isMoreButton: true)
    let thirdCheckView = JoinAgreementListCustomView(title: StringLiterals.Join.checkAge, isMoreButton: false)
    let fourthCheckView = JoinAgreementListCustomView(title: StringLiterals.Join.advertisementAgreement, isMoreButton: false)
    
    private let divisionLine = UIView().makeDivisionLine()
    
    private let JoinCompleteButton: UIButton = {
        let button = WableButton(type: .large, title: StringLiterals.Join.JoinCompleteButtonTitle, isEnabled: false)
        return button
    }()
    
    let JoinCompleteActiveButton: UIButton = {
        let button = WableButton(type: .large, title: StringLiterals.Join.JoinCompleteButtonTitle, isEnabled: true)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension JoinAgreementView {
    private func setUI() {
        allCheck.infoLabel.font = .body1
    }
    
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         allCheck,
                         firstCheckView,
                         secondCheckView,
                         thirdCheckView,
                         fourthCheckView,
                         divisionLine,
                         JoinCompleteButton,
                         JoinCompleteActiveButton)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(110.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        allCheck.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(36.adjustedH)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(48.adjusted)
        }
        
        divisionLine.snp.makeConstraints {
            $0.top.equalTo(allCheck.snp.bottom).offset(16.adjustedH)
            $0.leading.trailing.equalToSuperview().inset(28.adjusted)
            $0.height.equalTo(1.adjusted)
        }
        
        firstCheckView.snp.makeConstraints {
            $0.top.equalTo(divisionLine.snp.bottom).offset(16.adjustedH)
            $0.leading.trailing.height.equalTo(allCheck)
        }
        
        secondCheckView.snp.makeConstraints {
            $0.top.equalTo(firstCheckView.snp.bottom).offset(4.adjustedH)
            $0.leading.trailing.height.equalTo(allCheck)
        }
        
        thirdCheckView.snp.makeConstraints {
            $0.top.equalTo(secondCheckView.snp.bottom).offset(4.adjustedH)
            $0.leading.trailing.height.equalTo(allCheck)
        }
        
        fourthCheckView.snp.makeConstraints {
            $0.top.equalTo(thirdCheckView.snp.bottom).offset(4.adjustedH)
            $0.leading.trailing.height.equalTo(allCheck)
        }
        
        JoinCompleteButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(56.adjusted)
        }
        
        JoinCompleteActiveButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(56.adjusted)
        }
    }
}

