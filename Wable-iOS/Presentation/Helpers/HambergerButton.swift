//
//  HambergerButton.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/20/24.
//

import UIKit

import SnapKit

final class HambergerButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init() {
        super.init(frame: .zero)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        setImage(ImageLiterals.Button.btnHamberger, for: .normal)
        self.snp.makeConstraints {
            $0.size.equalTo(32.adjusted)
        }
    }
}
