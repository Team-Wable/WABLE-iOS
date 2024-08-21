//
//  MyPageReasonListCustomView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import UIKit

import SnapKit

final class MyPageReasonListCustomView: UIView {
    
    let radioButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnCheckboxDefault, for: .normal)
        button.setTitleColor(.wableBlack, for: .normal)
        button.titleLabel?.font = .body2
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4.adjusted, bottom: 0, right: -4.adjusted)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(reason: String) {
        super.init(frame: .zero)
        
        radioButton.setTitle(reason, for: .normal)
        
        self.addSubviews(radioButton)
        
        radioButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(48.adjusted)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
