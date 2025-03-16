//
//  LCKYearViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import UIKit

final class LCKYearViewController: UIViewController {
    
    
    // MARK: - LifeCycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
