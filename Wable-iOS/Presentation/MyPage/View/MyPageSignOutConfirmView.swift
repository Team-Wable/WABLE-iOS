//
//  MyPageSignOutConfirmView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import UIKit

class MyPageSignOutConfirmView: UIView {

    // MARK: - Properties
    
    var checkButtonState = false
    var signoutReason = ""
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = StringLiterals.MyPage.myPageSignOutConfirmTitle
        title.textColor = .wableBlack
        title.numberOfLines = 2
        title.font = .head0
        title.setTextWithLineHeight(text: title.text, lineHeight: 37.adjusted, alignment: .left)
        return title
    }()
    
    let signoutInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray100
        view.layer.cornerRadius = 8.adjusted
        return view
    }()
    
    private let infoDot1: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.textColor = .gray800
        label.font = UIFont.body2
        return label
    }()
    
    private let infoDot2: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.textColor = .gray800
        label.font = UIFont.body2
        return label
    }()
    
    let signoutInfo1Label: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(text: StringLiterals.MyPage.myPageSignOutConfirmInfo1, lineHeight: 20.adjusted, alignment: .left)
        label.textColor = .gray800
        label.font = .body2
        label.numberOfLines = 2
        return label
    }()
    
    let signoutInfo2Label: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(text: StringLiterals.MyPage.myPageSignOutConfirmInfo2, lineHeight: 20.adjusted, alignment: .left)
        label.textColor = .gray800
        label.font = .body2
        label.numberOfLines = 3
        return label
    }()
    
    let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnCheckboxDefault, for: .normal)
        return button
    }()
    
    private let checkInfoLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.MyPage.myPageSignOutConfirmInfo3
        label.textColor = .wableBlack
        label.font = UIFont.caption2
        return label
    }()
    
    let continueButton: UIButton = {
        let button = WableButton(type: .large, title: StringLiterals.MyPage.myPageSignOutContinueButtonTitle, isEnabled: false)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
        setRegisterCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension MyPageSignOutConfirmView {
    private func setUI() {

    }
    
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         signoutInfoView,
                         checkButton,
                         checkInfoLabel,
                         continueButton)
        
        signoutInfoView.addSubviews(infoDot1,
                                    infoDot2,
                                    signoutInfo1Label,
                                    signoutInfo2Label)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(28.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        signoutInfoView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(210.adjusted)
        }
        
        infoDot1.snp.makeConstraints {
            $0.top.equalTo(signoutInfo1Label.snp.top).inset(2.adjusted)
            $0.leading.equalToSuperview().inset(8.adjusted)
            $0.width.equalTo(10.adjusted)
        }
        
        signoutInfo1Label.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40.adjusted)
            $0.trailing.equalToSuperview().inset(8.adjusted)
            $0.leading.equalTo(infoDot1.snp.trailing).offset(6.adjusted)
        }
        
        infoDot2.snp.makeConstraints {
            $0.top.equalTo(signoutInfo2Label.snp.top).inset(2.adjusted)
            $0.leading.equalToSuperview().inset(8.adjusted)
            $0.width.equalTo(10.adjusted)
        }
        
        signoutInfo2Label.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(40.adjusted)
            $0.trailing.equalToSuperview().inset(8.adjusted)
            $0.leading.equalTo(infoDot1.snp.trailing).offset(6.adjusted)
        }
        
        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(48.adjusted)
            $0.bottom.equalTo(continueButton.snp.top).offset(-8.adjusted)
        }
        
        checkInfoLabel.snp.makeConstraints {
            $0.centerY.equalTo(checkButton.snp.centerY)
            $0.leading.equalTo(checkButton.snp.trailing).offset(4.adjusted)
        }
        
        continueButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
        }
    }
    
    private func setAddTarget() {
        
    }
    
    private func setRegisterCell() {
        
    }
    
    private func setDataBind() {
        
    }
}
