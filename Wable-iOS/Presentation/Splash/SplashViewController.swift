//
//  SplashViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

class SplashViewController: UIViewController {
    
    private let dontBeLogo: UIImageView = {
       let logo = UIImageView()
        logo.image = ImageLiterals.Logo.logoSymbolLarge
        return logo
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
    }
    
    private func setUI() {
        view.backgroundColor = .white
    }
    
    private func setLayout() {
        self.view.addSubview(dontBeLogo)
        dontBeLogo.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(146.adjusted)
            $0.height.equalTo(146.adjusted)
        }
    }

}
