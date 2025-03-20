//
//  AgreementView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

import Kingfisher

final class AgreementView: UIView {
    
    // MARK: - UIComponent
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = "와블 이용을 위해\n동의가 필요해요".pretendardString(with: .head0)
        $0.textColor = .wableBlack
        $0.numberOfLines = 2
    }
    
    let allAgreementItemView = AgreementItemView(title: "전체 선택", hasInformation: false)
    
    private let divideView: UIView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    let personalInfoAgreementItemView = AgreementItemView(title: "[필수] 이용약관 동의", hasInformation: true)
    
    let privacyPolicyAgreementItemView = AgreementItemView(title: "[필수] 개인정보 수집 및 이용동의", hasInformation: true)
    
    let ageAgreementItemView = AgreementItemView(title: "[필수] 만 14세 이상입니다", hasInformation: false)
    
    let marketingAgreementItemView = AgreementItemView(title: "마케팅 활용/광고성 정보 수신 동의", hasInformation: false)
    
    let nextButton: WableButton = WableButton(style: .gray).then {
        $0.configuration?.attributedTitle = "다음으로".pretendardString(with: .head2)
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension

private extension AgreementView {
    
    // MARK: Setup Method
    
    func setupView() {
        addSubviews(
            titleLabel,
            allAgreementItemView,
            divideView,
            personalInfoAgreementItemView,
            privacyPolicyAgreementItemView,
            ageAgreementItemView,
            marketingAgreementItemView,
            nextButton
        )
    }
    
    func setupConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
        }
        
        allAgreementItemView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(36)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        divideView.snp.makeConstraints {
            $0.top.equalTo(allAgreementItemView.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(allAgreementItemView).inset(12)
            $0.adjustedHeightEqualTo(1)
        }
        
        personalInfoAgreementItemView.snp.makeConstraints {
            $0.top.equalTo(divideView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        privacyPolicyAgreementItemView.snp.makeConstraints {
            $0.top.equalTo(personalInfoAgreementItemView.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        ageAgreementItemView.snp.makeConstraints {
            $0.top.equalTo(privacyPolicyAgreementItemView.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        marketingAgreementItemView.snp.makeConstraints {
            $0.top.equalTo(ageAgreementItemView.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(56)
        }
    }
}
