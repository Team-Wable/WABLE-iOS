//
//  WableSegmentedControl.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/26/25.
//

import UIKit

import Then

final class WableSegmentedControl: UISegmentedControl {
    
    // MARK: - UIComponent

    private lazy var underline = UIView(backgroundColor: .purple50).then {
        $0.frame.size = CGSize(width: Constant.underlineWidth, height: Constant.underlineHeight)
    }
    
    // MARK: - Life Cycles
    
    override init(items: [Any]?) {
        super.init(items: items)
        
        configureAppearance()
        updateUnderlinePosition(animated: false)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateUnderlinePosition(animated: true)
    }
}

// MARK: - Helper Method

private extension WableSegmentedControl {
    func configureAppearance() {
        addSubview(underline)
        
        let image = UIImage()
        setBackgroundImage(image, for: .normal, barMetrics: .default)
        setBackgroundImage(image, for: .selected, barMetrics: .default)
        setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    func updateUnderlinePosition(animated: Bool) {
        let newPosition = underlinePosition
        
        if animated {
            UIView.animate(withDuration: Constant.animationDuration) {
                self.underline.frame.origin = newPosition
            }
        } else {
            underline.frame.origin = newPosition
        }
    }
}

// MARK: - Computed Property

private extension WableSegmentedControl {
    var underlinePosition: CGPoint {
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        let xPosition = segmentWidth * CGFloat(selectedSegmentIndex) + (segmentWidth - Constant.underlineWidth) / 2
        let yPosition = bounds.height - Constant.underlineHeight
        
        return CGPoint(x: xPosition, y: yPosition)
    }
}

// MARK: - Constant

private extension WableSegmentedControl {
    enum Constant {
        static let underlineWidth: CGFloat = 28.adjustedWidth
        static let underlineHeight: CGFloat = 2.adjustedHeight
        static let animationDuration: TimeInterval = 0.1
    }
}
