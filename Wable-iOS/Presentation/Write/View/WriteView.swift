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
    
    let writeTextView = WriteTextView()
    
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
        self.addSubviews(writeTextView)
    }
    
    func setLayout() {
        writeTextView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setAddTarget() {
        
    }
    
    @objc
    private func cancleButtonTapped() {

    }
    
    @objc
    private func postButtonTapped() {
        
    }
}
