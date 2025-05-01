//
//  ViewitURLInputView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/1/25.
//

import UIKit

import SnapKit
import Then

final class ViewitURLInputView: UIView {
    
    // MARK: - UIComponent
    
    let imageViewBackgroundView = UIView().then {
        $0.isHidden = true
    }
    
    let urlIconImageView = UIImageView(image: .icLink)
    
    let urlTextField = UITextField(pretendard: .body4, placeholder: Constant.placeholder).then {
        $0.tintColor = .purple50
        $0.textColor = .blue50
        $0.backgroundColor = .gray100
        $0.layer.cornerRadius = 16
        $0.addPadding(left: 8, right: 8)
        $0.keyboardType = .URL
        $0.autocapitalizationType = .none
    }
    
    let buttonBackgroundView = UIView().then {
        $0.isHidden = false
    }
    
    let nextButton = UIButton().then {
        $0.setImage(.btnLink.withRenderingMode(.alwaysOriginal), for: .disabled)
        $0.setImage(.btnLinkPress, for: .normal)
        $0.isEnabled = false
    }
    
    // MARK: - Initializer

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

private extension ViewitURLInputView {
    
    // MARK: - Setup Method

    func setupView() {
        imageViewBackgroundView.addSubview(urlIconImageView)
        
        buttonBackgroundView.addSubview(nextButton)
        
        let stackView = UIStackView(
            arrangedSubviews: [imageViewBackgroundView, urlTextField, buttonBackgroundView]
        ).then {
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        urlIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.adjustedWidthEqualTo(Constant.linkImageSize)
            make.adjustedHeightEqualTo(Constant.linkImageSize)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.adjustedHeightEqualTo(Constant.textFieldHeight)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.adjustedWidthEqualTo(Constant.linkImageSize)
            make.adjustedHeightEqualTo(Constant.linkImageSize)
        }
    }
    
    // MARK: - Constant

    enum Constant {
        static let placeholder = "공유하고 싶은 동영상 링크를 입력해주세요."
        static let textFieldHeight: CGFloat = 40
        static let linkImageSize: CGFloat = 32
    }
}
