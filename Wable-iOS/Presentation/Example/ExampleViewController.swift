//
//  ExampleViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

final class ExampleViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - UI Components
    
    private let myView = ExampleView()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = myView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPI()
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
    }
}

// MARK: - Extensions

extension ExampleViewController {
    private func setUI() {
        
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {
        
    }
}

// MARK: - Network

extension ExampleViewController {
    private func getAPI() {
        
    }
}

//extension ExampleViewController: UICollectionViewDelegate {
//
//}
//
//extension ExampleViewController: UICollectionViewDataSource {
//
//}
//
//extension ExampleViewController: UICollectionViewFlowLayout {
//
//}
