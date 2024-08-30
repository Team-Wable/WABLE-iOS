//
//  InfoRankingViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit
import Combine

final class InfoRankingViewController: UIViewController {
    
    // MARK: - Properties
    
    
    // MARK: - UI Components
    
    let rankingView = RankingView()

    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = rankingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPI()
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Extensions

extension InfoRankingViewController {
    private func setUI() {
        
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {

    }
    
    private func bindViewModel() {

    }
}

// MARK: - Network

extension InfoRankingViewController {
    private func getAPI() {
        
    }
}
