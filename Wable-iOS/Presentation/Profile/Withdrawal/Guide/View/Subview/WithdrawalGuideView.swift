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
        config?.title = "계속"
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
            $0.attributedText = Constant.title.pretendardString(with: .head0)
            $0.numberOfLines = 0
        }
        
        let firstDescriptionView = WithdrawalGuideDescriptionView().then {
            $0.configure(description: Constant.firstDescription)
        }
        let secondDescriptionView = WithdrawalGuideDescriptionView().then {
            $0.configure(description: Constant.secondDescription)
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
            $0.attributedText = Constant.message.pretendardString(with: .caption2)
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
    
    enum Constant {
        static let title = """
                        계정을 삭제하기 전,
                        아래 내용을 꼭 확인해 주세요
                        """
        static let firstDescription = "계정 삭제 처리된 이메일 아이디는 재가입 방지를 위해 30일간 보존된 후 삭제 처리됩니다."
        static let secondDescription = "탈퇴와 재가입을 통해 아이디를 교체하며 선량한 이용자들께 피해를 끼치는 행위를 방지하려는 조치 오니 넓은 양해 부탁드립니다."
        static let message = "안내사항을 모두 확인하였으며, 이에 동의합니다."
    }
}
