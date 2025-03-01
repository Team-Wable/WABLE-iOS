//
//  ViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//

import UIKit

import Then
import SnapKit

class ViewController: UIViewController {
    private let testLabel = UILabel().then {
        $0.text = "클린 LCK 팬 커뮤니티\n와블에서 함께 해요"
        $0.setLabel(.head0)
        $0.textColor = .wableBlack
        $0.numberOfLines = 2
        $0.textAlignment = .center
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Setup Method

    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(testLabel)
        
        testLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(148)
        }
    }
}

