//
//  WithdrawalReasonCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then

final class WithdrawalReasonCell: UICollectionViewCell {
    
    // MARK: - UIComponent

    private let checkboxButton = UIButton().then {
        $0.setImage(.btnCheckboxDefault, for: .normal)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.attributedText = "설명".pretendardString(with: .body2)
    }
    
    // MARK: - Property

    var checkboxDidTapClosure: VoidClosure?
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
        setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isSelected: Bool, description: String) {
        checkboxButton.setImage(isSelected ? .btnCheckboxActive : .btnCheckboxDefault, for: .normal)

        descriptionLabel.text = description
    }
}

private extension WithdrawalReasonCell {
    
    // MARK: - Setup Method

    func setupCell() {
        contentView.addSubviews(checkboxButton, descriptionLabel)
        
        checkboxButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(48)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkboxButton)
            make.leading.equalTo(checkboxButton.snp.trailing).offset(4)
        }
    }
    
    func setupAction() {
        checkboxButton.addTarget(self, action: #selector(checkboxButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Action Method

    @objc func checkboxButtonDidTap() {
        checkboxDidTapClosure?()
    }
}
