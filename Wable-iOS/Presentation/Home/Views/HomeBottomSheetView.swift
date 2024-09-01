//
//  HomeBottomSheetView.swift
//  Wable-iOS
//
//  Created by 변상우 on 9/1/24.
//

import UIKit

import SnapKit

final class HomeBottomSheetView: UIView {
    
    // MARK: - Properties
    
    var initialPosition: CGPoint = CGPoint(x: 0, y: 0)
    var isUser: Bool = true
    
    // MARK: - UI Components
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        return view
    }()
    
    let bottomsheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableWhite
        view.layer.cornerRadius = 16.adjusted
        return view
    }()
    
    private let dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray500
        view.layer.cornerRadius = 2.adjusted
        return view
    }()
    
    let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.BottomSheet.report, for: .normal)
        button.setTitleColor(.wableBlack, for: .normal)
        button.titleLabel?.font = .body1
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.BottomSheet.delete, for: .normal)
        button.setTitleColor(.wableBlack, for: .normal)
        button.titleLabel?.font = .body1
        return button
    }()
    
    // MARK: - Life Cycles
    
    init() {
        super.init(frame: .zero)
        
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

extension HomeBottomSheetView {
    private func setHierarchy() {
        self.addSubviews(dimView,
                         bottomsheetView)
        bottomsheetView.addSubviews(dragIndicatorView,
                                    reportButton,
                                    deleteButton)
    }
    
    private func setLayout() {
        bottomsheetView.snp.makeConstraints {
            $0.height.equalTo(122.adjusted)
        }
        
        dragIndicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(42.adjusted)
            $0.height.equalTo(2.adjusted)
            $0.top.equalTo(16.adjusted)
        }
        
        reportButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(dragIndicatorView).offset(28.adjusted)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(dragIndicatorView).offset(28.adjusted)
        }
    }
    
    private func setAddTarget() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlepanGesture))
        bottomsheetView.addGestureRecognizer(panGesture)
    }
    
    func showSettings() {
        if let window = UIApplication.shared.keyWindowInConnectedScenes {
            dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubviews(dimView, bottomsheetView)
            
            dimView.frame = window.frame
            dimView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.dimView.alpha = 1
                
                self.bottomsheetView.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalTo(window.snp.bottom)
                    $0.leading.trailing.equalToSuperview()
                }
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        if UIApplication.shared.keyWindowInConnectedScenes != nil {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.dimView.alpha = 0
                if let window = UIApplication.shared.keyWindowInConnectedScenes {
                    self.bottomsheetView.frame = CGRect(x: 0, y: window.frame.height, width: self.bottomsheetView.frame.width, height: self.bottomsheetView.frame.height)
                }
            })
            dimView.removeFromSuperview()
            bottomsheetView.removeFromSuperview()
        }
            
    }
    
    @objc private func handlepanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            initialPosition = self.center
        case .changed:
            self.center = CGPoint(x: initialPosition.x, y: initialPosition.y + translation.y)
        case .ended:
            if self.frame.origin.y < 512.adjusted {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.dimView.alpha = 0
                    if let window = UIApplication.shared.keyWindowInConnectedScenes {
                        self.bottomsheetView.frame = CGRect(x: 0, y: window.frame.height, width: self.bottomsheetView.frame.width, height: self.bottomsheetView.frame.height)
                    }
                })
                dimView.removeFromSuperview()
                bottomsheetView.removeFromSuperview()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame.origin = self.initialPosition
                })
            }
        default:
            break
        }
    }
}
