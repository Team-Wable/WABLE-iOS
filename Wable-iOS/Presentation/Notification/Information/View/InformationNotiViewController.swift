//
//  InformationNotiViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/29/25.
//

import UIKit

import SnapKit
import Then

final class InformationNotiViewController: UIViewController {
    
    // MARK: - Section

    enum Section {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = InfoNotification
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDataSource()
    }
}

// MARK: - Setup Method

private extension InformationNotiViewController {
    func setupView() {
        
    }
    
    func setupConstraint() {
        
    }
    
    func setupDataSource() {
        
    }
}

// MARK: - Helper Method

private extension InformationNotiViewController {
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapshot)
    }
}

// MARK: - Computed Propert

private extension InformationNotiViewController {
    
}
