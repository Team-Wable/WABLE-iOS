//
//  ViewitContentInputView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/1/25.
//

import UIKit

import Lottie
import SnapKit
import Then

final class ViewitContentInputView: UIView {
    
    // MARK: - UIComponent

    let contentTextField = UITextField(pretendard: .body4, placeholder: Constant.placeholder).then {
        $0.tintColor = .purple50
        $0.backgroundColor = .gray100
        $0.layer.borderColor = UIColor.gray100.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
        $0.addPadding(left: 8, right: 8)
        $0.autocapitalizationType = .none
    }
    
    let writeButton = UIButton().then {
        $0.setImage(.btnRippleDefault, for: .disabled)
        $0.setImage(.btnRipplePress, for: .normal)
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

private extension ViewitContentInputView {
    
    // MARK: - Setup Method

    func setupView() {
        let topAnimationView = LottieAnimationView(name: LottieType.tab.rawValue).then {
            $0.contentMode = .scaleToFill
            $0.loopMode = .loop
            $0.play()
        }
        
        addSubviews(topAnimationView, contentTextField, writeButton)
        
        topAnimationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(2)
        }
        
        contentTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(16)
            make.adjustedHeightEqualTo(Constant.textFieldHeight)
        }
        
        writeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(contentTextField)
            make.adjustedWidthEqualTo(32)
            make.adjustedHeightEqualTo(32)
        }
    }
    
    // MARK: - Constant
    
    enum Constant {
        static let placeholder = "어떤 내용의 링크인가요?"
        static let textFieldHeight: CGFloat = 40
    }
}
