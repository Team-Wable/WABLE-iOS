//
//  FeedBottomWriteView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

import UIKit

import SnapKit
import Lottie

final class FeedBottomWriteView: UIView {
    
    // MARK: - Properties
    
    // MARK: - UI Components
    
    private lazy var tabLottieAnimationView: LottieAnimationView = {
        let animation = LottieAnimationView(name: "wable_tab")
        animation.contentMode = .scaleAspectFill
        animation.loopMode = .loop
        animation.play()
        return animation
    }()
    
    var writeTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 16.adjusted
        textView.backgroundColor = .gray100
        textView.font = .body4
        textView.textColor = .gray700
        return textView
    }()
    
    var uploadButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnRippleDefault, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension FeedBottomWriteView {
    private func setUI() {
        self.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(tabLottieAnimationView,
                         writeTextView,
                         uploadButton)
    }
    
    private func setLayout() {
        tabLottieAnimationView.snp.makeConstraints {
            $0.height.equalTo(2.adjusted)
            $0.leading.trailing.top.equalToSuperview()
        }
        
        writeTextView.snp.makeConstraints {
            $0.height.equalTo(42.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.trailing.equalTo(uploadButton.snp.leading).offset(-6.adjusted)
            $0.centerY.equalToSuperview()
        }
        
        uploadButton.snp.makeConstraints {
            $0.height.width.equalTo(32.adjusted)
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.centerY.equalTo(writeTextView)
        }
    }
    
    private func setAddTarget() {

    }
}
