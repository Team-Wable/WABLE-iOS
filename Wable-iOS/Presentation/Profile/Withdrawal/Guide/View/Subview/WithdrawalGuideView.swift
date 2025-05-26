//
//  WithdrawalGuideView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then

final class WithdrawalGuideView: UIView {
    
    let navigationView = NavigationView(type: .page(type: .detail, title: "계정 삭제"))
    
    let checkboxButton = UIButton().then {
        $0.setImage(.btnCheckboxDefault, for: .normal)
    }
    
    let nextButton = WableButton(style: .gray).then {
        var config = $0.configuration
        config?.attributedTitle = "계속".pretendardString(with: .head2)
        $0.configuration = config
        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .wableWhite
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WithdrawalGuideView {
    
    func setupView() {
        let titleLabel = UILabel().then {
            $0.attributedText = StringLiterals.ProfileDelete.withdrawalGuideTitle.pretendardString(with: .head0)
            $0.numberOfLines = 0
        }
        
        let firstDescriptionView = WithdrawalGuideDescriptionView().then {
            $0.configure(description: StringLiterals.ProfileDelete.withdrawalGuideDescription1)
        }
        let secondDescriptionView = WithdrawalGuideDescriptionView().then {
            $0.configure(description: StringLiterals.ProfileDelete.withdrawalGuideDescription2)
        }
        
        let descriptionStackView = UIStackView(arrangedSubviews: [firstDescriptionView, secondDescriptionView]).then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        let descriptionBackgroundView = UIView(backgroundColor: .gray100).then {
            $0.layer.cornerRadius = 12
        }
        
        descriptionBackgroundView.addSubview(descriptionStackView)
        
        let messageLabel = UILabel().then {
            $0.attributedText = StringLiterals.ProfileDelete.checkboxTitle.pretendardString(with: .caption2)
        }
        
        addSubviews(navigationView, titleLabel, descriptionBackgroundView, checkboxButton, messageLabel, nextButton)
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(descriptionBackgroundView.snp.top).offset(-48)
        }
        
        descriptionBackgroundView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        descriptionStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(36)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        
        checkboxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(48)
            make.bottom.equalTo(nextButton.snp.top).offset(-12)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkboxButton)
            make.leading.equalTo(checkboxButton.snp.trailing).offset(4)
        }
        
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(safeArea).offset(-24)
            make.adjustedHeightEqualTo(56)
        }
    }
}
