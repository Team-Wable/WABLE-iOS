//
//  WableButton.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/12/25.
//

import UIKit

final class WableButton: UIButton {
    
    // MARK: - WableButton Style

    enum Style {
        case primary
        case pale
        case gray
        case black
    }
    
    // MARK: - Property

    private var style: WableButton.Style {
        didSet {
            setupButton()
        }
    }
    
    // MARK: - Initializer

    init(style: WableButton.Style) {
        self.style = style
        
        super.init(frame: .zero)
        
        setupButton()
    }
    
    override init(frame: CGRect) {
        self.style = .primary
        
        super.init(frame: frame)
        
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateStyle(_ style: WableButton.Style) {
        self.style = style
    }
}

// MARK: - Setup Method

private extension WableButton {
    func setupButton() {
        var configuration = self.configuration ?? .filled()
        
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = style.backgroundColor
        configuration.baseForegroundColor = style.foregroundColor
        
        self.configuration = configuration
    }
}

fileprivate extension WableButton.Style {
    var foregroundColor: UIColor {
        switch self {
        case .primary:
            return .wableWhite
        case .pale:
            return .purple50
        case .gray:
            return .gray600
        case .black:
            return .wableWhite
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .primary:
            return .purple50
        case .pale:
            return .purple10
        case .gray:
            return .gray200
        case .black:
            return .wableBlack
        }
    }
}
