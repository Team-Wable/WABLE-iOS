//
//  JoinAgreementListCustomView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

import SnapKit

final class JoinAgreementListCustomView: UIView {
    
    let checkButton: UIButton = {
        let checkButton = UIButton()
        checkButton.setImage(ImageLiterals.Button.btnCheckboxDefault, for: .normal)
        return checkButton
    }()
    
    let infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.textColor = .wableBlack
        infoLabel.font = .body2
        return infoLabel
    }()
    
    let moreButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.Join.JoinAgreementMoreButtonTitle, for: .normal)
        button.setTitleColor(.gray500, for: .normal)
        button.titleLabel?.font = .body4
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(title: String, isMoreButton: Bool) {
        super.init(frame: .zero)
        
        infoLabel.text = title
        
        if isMoreButton {
            self.addSubviews(checkButton,
                             infoLabel,
                             moreButton)
            
            checkButton.snp.makeConstraints {
                $0.top.leading.equalToSuperview()
                $0.size.equalTo(48.adjusted)
                $0.centerY.equalTo(infoLabel)
            }
            
            infoLabel.snp.makeConstraints {
                $0.leading.equalTo(checkButton.snp.trailing).offset(4.adjusted)
                $0.centerY.equalTo(checkButton)
            }
            
            moreButton.snp.makeConstraints {
                $0.leading.equalTo(infoLabel.snp.trailing).offset(6.adjusted)
                $0.centerY.equalTo(infoLabel)
            }
        } else {
            self.addSubviews(checkButton,
                             infoLabel)
            
            checkButton.snp.makeConstraints {
                $0.top.leading.equalToSuperview()
                $0.size.equalTo(48.adjusted)
                $0.centerY.equalTo(infoLabel)
            }
            
            infoLabel.snp.makeConstraints {
                $0.leading.equalTo(checkButton.snp.trailing).offset(4.adjusted)
                $0.centerY.equalTo(checkButton)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
