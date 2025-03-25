//
//  WableBadgeSegmentedControl.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import UIKit

import SnapKit

final class WableBadgeSegmentedControl: UIControl {
    
    // MARK: - UI Component
    
    private var buttons = [UIButton]()
    private var badgeViews = [UIView]()
    
    private let underlineView = UIView()
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    // MARK: - Property
    
    var selectedSegmentIndex: Int = 0 {
        didSet {
            updateSelectedButtonColors()
            updateUnderline(animated: true)
        }
    }
    
    // MARK: - Initializer
    
    init(items: [String]) {
        super.init(frame: .zero)
        
        setupView()
        setupConstraints()
        setupButtons(with: items)
        setupUnderlineView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutBadges()
        updateUnderline(animated: false)
    }
}

extension WableBadgeSegmentedControl {
    func showBadge(at index: Int) {
        guard isValidIndex(index) else { return }
        badgeViews[index].isHidden = false
    }
    
    func hideBadge(at index: Int) {
        guard isValidIndex(index) else { return }
        badgeViews[index].isHidden = true
    }
}

// MARK: - Private Method

private extension WableBadgeSegmentedControl {
    enum Constants {
        static let badgeSize: CGFloat = 4
        static let underlineHeight: CGFloat = 2
    }
    
    func setupView() {
        backgroundColor = .wableWhite
        
        addSubview(buttonStackView)
    }
    
    func setupConstraints() {
        buttonStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(Constants.underlineHeight)
        }
    }
    
    func setupButtons(with items: [String]) {
        items.enumerated().forEach { index, title in
            let button = createButton(title: title, tag: index)
            buttonStackView.addArrangedSubview(button)
            buttons.append(button)
            
            let badgeView = createBadgeView()
            addSubview(badgeView)
            badgeViews.append(badgeView)
        }
    }
    
    func setupUnderlineView() {
        underlineView.backgroundColor = .purple50
        addSubview(underlineView)
    }
    
    func layoutBadges() {
        buttons.enumerated().forEach { index, button in
            guard let titleLabel = button.titleLabel else { return }
            let titleSize = titleLabel.intrinsicContentSize
            
            badgeViews[index].frame = CGRect(
                x: button.frame.origin.x + titleLabel.frame.origin.x + titleSize.width - 2,
                y: titleLabel.frame.origin.y - Constants.badgeSize,
                width: Constants.badgeSize,
                height: Constants.badgeSize
            )
        }
    }
    
    func updateSelectedButtonColors() {
        buttons.enumerated().forEach { index, button in
            let color: UIColor = index == selectedSegmentIndex ? .purple50 : .gray500
            button.setTitleColor(color, for: .normal)
        }
    }
    
    func updateUnderline(animated: Bool = false) {
        guard isValidIndex(selectedSegmentIndex) else { return }
        
        let selectedButton = buttons[selectedSegmentIndex]
        let titleSize = selectedButton.titleLabel?.intrinsicContentSize ?? .zero
        let underlineWidth = titleSize.width
        
        let targetFrame = CGRect(
            x: selectedButton.center.x - underlineWidth / 2,
            y: self.frame.height - Constants.underlineHeight,
            width: underlineWidth,
            height: Constants.underlineHeight
        )
        
        animated ? animateUnderline(to: targetFrame) : (underlineView.frame = targetFrame)
    }
    
    func animateUnderline(to frame: CGRect) {
        UIView.animate(withDuration: 0.2) {
            self.underlineView.frame = frame
        }
    }
    
    func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray500, for: .normal)
        button.titleLabel?.font = .pretendard(.body1)
        button.tag = tag
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        return button
    }
    
    @objc
    func buttonDidTap(_ sender: UIButton) {
        selectedSegmentIndex = sender.tag
        sendActions(for: .valueChanged)
    }
    
    func createBadgeView() -> UIView {
        let badgeView = UIView()
        badgeView.backgroundColor = .red
        badgeView.layer.cornerRadius = Constants.badgeSize / 2
        badgeView.isHidden = true
        return badgeView
    }
    
    func isValidIndex(_ index: Int) -> Bool {
        return index >= 0 && index < buttons.count
    }
}
