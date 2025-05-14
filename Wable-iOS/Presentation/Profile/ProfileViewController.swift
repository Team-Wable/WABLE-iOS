//
//  ProfileViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import UIKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .infoDark).then {
            $0.setTitle("시방", for: .normal)
        }
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let vc = ProfileEditViewController()
        
        button.addAction(UIAction(handler: { _ in
            self.navigationController?.pushViewController(vc, animated: true)
        }), for: .touchUpInside)
    }
}
