//
//  MyPageSignOutView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import UIKit

class MyPageSignOutView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = StringLiterals.MyPage.myPageSignOutTitle
        title.textColor = .wableBlack
        title.font = .head0
        return title
    }()
    
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.MyPage.myPageSignOutSubTitle
        label.textColor = .gray600
        label.font = .body2
        label.numberOfLines = 2
        label.setTextWithLineHeight(text: label.text, lineHeight: 27.adjusted, alignment: .left)
        return label
    }()
    
    let firstReasonView = MyPageReasonListCustomView(reason: StringLiterals.MyPage.myPageSignOutReason1)
    let secondReasonView = MyPageReasonListCustomView(reason: StringLiterals.MyPage.myPageSignOutReason2)
    let thirdReasonView = MyPageReasonListCustomView(reason: StringLiterals.MyPage.myPageSignOutReason3)
    let fourthReasonView = MyPageReasonListCustomView(reason: StringLiterals.MyPage.myPageSignOutReason4)
    let fifthReasonView = MyPageReasonListCustomView(reason: StringLiterals.MyPage.myPageSignOutReason5)
    let sixthReasonView = MyPageReasonListCustomView(reason: StringLiterals.MyPage.myPageSignOutReason6)
    let seventhReasonView = MyPageReasonListCustomView(reason: StringLiterals.MyPage.myPageSignOutReason7)
    
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

extension MyPageSignOutView {
    private func setUI() {
        firstReasonView.radioButton.titleLabel?.font = .body2
        secondReasonView.radioButton.titleLabel?.font = .body2
        thirdReasonView.radioButton.titleLabel?.font = .body2
        fourthReasonView.radioButton.titleLabel?.font = .body2
        fifthReasonView.radioButton.titleLabel?.font = .body2
        sixthReasonView.radioButton.titleLabel?.font = .body2
        seventhReasonView.radioButton.titleLabel?.font = .body2
    }
    
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         subTitleLabel,
                         firstReasonView,
                         secondReasonView,
                         thirdReasonView,
                         fourthReasonView,
                         fifthReasonView,
                         sixthReasonView,
                         seventhReasonView,
                         continueButton)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(28.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6.adjustedH)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        firstReasonView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(28.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
        }
        
        secondReasonView.snp.makeConstraints {
            $0.top.equalTo(firstReasonView.snp.bottom).offset(4.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
        }
        
        thirdReasonView.snp.makeConstraints {
            $0.top.equalTo(secondReasonView.snp.bottom).offset(4.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
        }
        
        fourthReasonView.snp.makeConstraints {
            $0.top.equalTo(thirdReasonView.snp.bottom).offset(4.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
        }
        
        fifthReasonView.snp.makeConstraints {
            $0.top.equalTo(fourthReasonView.snp.bottom).offset(4.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
        }
        
        sixthReasonView.snp.makeConstraints {
            $0.top.equalTo(fifthReasonView.snp.bottom).offset(4.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
        }
        
        seventhReasonView.snp.makeConstraints {
            $0.top.equalTo(sixthReasonView.snp.bottom).offset(4.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
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
