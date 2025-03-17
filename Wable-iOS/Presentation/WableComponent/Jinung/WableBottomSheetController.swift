//
//  WableBottomSheetController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/15/25.
//

import UIKit

import SnapKit
import Then

// MARK: - WableBottomSheetAction

struct WableBottomSheetAction {
    let title: String
    let handler: (() -> Void)?
    
    init(title: String, handler: (() -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }
}

// MARK: - WableBottomSheetController

final class WableBottomSheetController: UIViewController {
    
    // MARK: - UIComponent
    
    private let dimmedBackgroundView = UIView().then {
        $0.backgroundColor = .wableBlack.withAlphaComponent(.zero)
        $0.isUserInteractionEnabled = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .wableWhite
        $0.roundCorners([.top], radius: 16)
    }
    
    private let grabberView = UIView().then {
        $0.backgroundColor = .gray500
        $0.layer.cornerRadius = Constant.grabberHeight / 2
    }

    private let buttonStackView = UIStackView(axis: .vertical).then {
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: Constant.animationDuration) {
            self.view.backgroundColor = .wableBlack.withAlphaComponent(Constant.defaultAlpha)
            self.containerView.frame.origin.y = self.view.bounds.height - self.containerViewHeight
        }
    }
}

// MARK: - Public Method

extension WableBottomSheetController {
    func addAction(_ action: WableBottomSheetAction) {
        let buttonAction = UIAction { [weak self] _ in
            self?.dismissWithAnimation(handler: action.handler)
        }
        
        let button = UIButton().then {
            $0.setAttributedTitle(action.title.pretendardString(with: .body1), for: .normal)
            $0.setTitleColor(.wableBlack, for: .normal)
            $0.addAction(buttonAction, for: .touchUpInside)
        }
        
        button.snp.makeConstraints { make in
            make.adjustedHeightEqualTo(Constant.buttonHeight)
        }
        
        buttonStackView.addArrangedSubview(button)
    }
    
    func addActions(_ actions: WableBottomSheetAction...) {
        actions.forEach { addAction($0) }
    }
}

// MARK: - Private Method

private extension WableBottomSheetController {
    func dismissWithAnimation(handler: (() -> Void)? = nil) {
        UIView.animate(withDuration: Constant.animationDuration) {
            self.view.backgroundColor = .black.withAlphaComponent(.zero)
            self.containerView.frame.origin.y = self.view.bounds.height
        } completion: { _ in
            self.dismiss(animated: false) {
                handler?()
            }
        }
    }
}

// MARK: - Setup Method

private extension WableBottomSheetController {
    func setupView() {
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        
        view.addSubviews(
            dimmedBackgroundView,
            containerView
        )
        
        containerView.addSubviews(
            grabberView,
            buttonStackView
        )
    }
    
    func setupConstraint() {
        dimmedBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.frame = .init(x: 0, y: view.bounds.height, width: view.bounds.width, height: containerViewHeight)
        
        grabberView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.padding)
            make.centerX.equalToSuperview()
            make.adjustedWidthEqualTo(44)
            make.adjustedHeightEqualTo(2)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.padding * 2)
            make.centerX.equalToSuperview()
            make.adjustedWidthEqualTo(150)
        }
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedBackgroundViewTapped))
        dimmedBackgroundView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - objc Method

private extension WableBottomSheetController {
    @objc func dimmedBackgroundViewTapped() {
        dismissWithAnimation()
    }
}

// MARK: - Computed Property

private extension WableBottomSheetController {
    var containerViewHeight: CGFloat {
        return CGFloat(buttonStackView.arrangedSubviews.count) * Constant.buttonHeight + 5 * Constant.padding
    }
}

// MARK: - Constant

private extension WableBottomSheetController {
    enum Constant {
        static let padding: CGFloat = 16
        static let buttonHeight: CGFloat = 56
        static let animationDuration: CGFloat = 0.2
        static let defaultAlpha: CGFloat = 0.5
        static let grabberHeight: CGFloat = 2
    }
}
