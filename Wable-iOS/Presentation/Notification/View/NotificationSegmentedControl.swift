//
//  NotificationSegmentedControl.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

class NotificationSegmentedControl: UISegmentedControl {
    private lazy var underlineView: UIView = {
        let width: CGFloat = 28.adjusted
        let height: CGFloat = 2.adjusted
        let segmentWidth = self.bounds.width / CGFloat(self.numberOfSegments)
        let xPosition = segmentWidth * CGFloat(self.selectedSegmentIndex) + (segmentWidth - width) / 2
        let yPosition = self.bounds.height - height
        let view = UIView(frame: CGRect(x: xPosition, y: yPosition, width: width, height: height))
        view.backgroundColor = .purple50
        self.addSubview(view)
        return view
    }()
    
    // MARK: - Life Cycles
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.removeBackgroundAndDivider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let segmentWidth = self.bounds.width / CGFloat(self.numberOfSegments)
        let underlineFinalXPosition = segmentWidth * CGFloat(self.selectedSegmentIndex) + (segmentWidth - underlineView.bounds.width) / 2
        
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.underlineView.frame.origin.x = underlineFinalXPosition
            }
        )
    }
    
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        
        setBackgroundImage(image, for: .normal, barMetrics: .default)
        setBackgroundImage(image, for: .selected, barMetrics: .default)
        setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
}
