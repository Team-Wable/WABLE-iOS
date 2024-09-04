//
//  WriteView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/23/24.
//

import UIKit

import SnapKit

final class WriteView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    private let topDivisionLine = UIView().makeDivisionLine()
    let writeTextView = WriteTextView()
//    let writeCanclePopupView = DontBePopupView(popupTitle: "",
//                                               popupContent: StringLiterals.Write.writePopupContentLabel,
//                                               leftButtonTitle: StringLiterals.Write.writePopupCancleButtonTitle,
//                                               rightButtonTitle: StringLiterals.Write.writePopupConfirmButtonTitle)
    
    // MARK: - Life Cycles
    
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

extension WriteView {
    func setUI() {
        self.backgroundColor = .wableWhite
    }
    
    func setHierarchy() {
        self.addSubviews(topDivisionLine, writeTextView)
        
//        if let window = UIApplication.shared.keyWindowInConnectedScenes {
//            window.addSubviews(writeCanclePopupView)
//        }
    }
    
    func setLayout() {
        topDivisionLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(1.adjusted)
        }
        
        writeTextView.snp.makeConstraints {
            $0.top.equalTo(topDivisionLine.snp.bottom)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
//        writeCanclePopupView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
    }
    
    func setAddTarget() {
        
    }
    
    @objc
    private func cancleButtonTapped() {
//        writeCanclePopupView.alpha = 0
    }
    
    @objc
    private func postButtonTapped() {
        
    }
}
