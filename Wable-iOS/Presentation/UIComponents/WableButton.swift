//
//  WableButton.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/7/24.
//

import UIKit

import SnapKit

enum ButtonStatus {
    case large
    case medium
    case small
    case nameCheck
}

final class WableButton: UIButton {

    private enum Size {
        static let largeHeight: CGFloat = 56.adjusted
        static let mediumHeight: CGFloat = 48.adjusted
        static let smallHeight: CGFloat = 48.adjusted
        static let smallWidth: CGFloat = 136.adjusted
        static let nameCheckHeight: CGFloat = 48.adjusted
        static let nameCheckWidth: CGFloat = 94.adjusted
    }

    // MARK: - Properties

    private var buttonStatus: ButtonStatus
    private var title: String
    override var isEnabled: Bool {
        didSet {
            setButtonState(as: isEnabled)
        }
    }

    // MARK: - inits

    init(type: ButtonStatus, title: String, isEnabled: Bool) {
        self.title = title
        self.buttonStatus = type
        super.init(frame: .zero)
        self.isEnabled = isEnabled
        
        configureUI(type: type)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setLayout(type: buttonStatus)
    }

    // MARK: - Functions

    private func configureUI(type: ButtonStatus) {
        self.clipsToBounds = true
        self.setTitle(self.title, for: .normal)
        
        switch type {
        case .nameCheck:
            self.layer.cornerRadius = 6.adjusted
            self.titleLabel?.font = .body3

        default :
            self.layer.cornerRadius = 12.adjusted
            self.titleLabel?.font = .head2
        }
    }

    private func setLayout(type: ButtonStatus) {
        switch type {
        case .large:
            self.snp.makeConstraints {
                $0.height.equalTo(Size.largeHeight)
            }
        case .medium:
            self.snp.makeConstraints {
                $0.height.equalTo(Size.mediumHeight)
            }
        case .small:
            self.snp.makeConstraints {
                $0.height.equalTo(Size.smallHeight)
                $0.width.equalTo(Size.smallWidth)
            }
        case .nameCheck:
            self.snp.makeConstraints {
                $0.height.equalTo(Size.nameCheckHeight)
                $0.width.equalTo(Size.nameCheckWidth)
            }
        }
    }

    private func setButtonState(as isEnabled: Bool) {
        if isEnabled {
            enabledState(type: buttonStatus)
        } else {
            disabledState()
        }
    }
    
    private func enabledState(type: ButtonStatus) {
        switch type {
        case .nameCheck:
            self.backgroundColor = .gray900
            self.setTitleColor(.gray100, for: .normal)
        default:
            self.backgroundColor = .purple50
            self.setTitleColor(.wableWhite, for: .normal)
        }
    }
    
    private func disabledState() {
        self.setTitleColor(.gray600, for: .disabled)
        self.backgroundColor = .gray200
    }
}
