//
//  ActivityNotiViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/26/25.
//

import Combine
import UIKit

import SnapKit
import Then

final class ActivityNotiViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    // MARK: - typealias

    typealias Item = ActivityNotification
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property

    private var dataSource: DataSource?
    
    private let didLoadSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let didSelectItemSubject = PassthroughSubject<Int, Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let profileImageViewDidTapSubject = PassthroughSubject<Int, Never>()
    private let cancelBag = CancelBag()
    
    // MARK: - UIComponent

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let emptyLabel = UILabel().then {
        $0.attributedText = "아직 표시할 내용이 없습니다.".pretendardString(with: .body2)
        $0.textColor = .gray500
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDataSource()
        setupAction()
        setupDelegate()
        
        didLoadSubject.send()
    }
}

// MARK: - UICollectionViewDelegate

extension ActivityNotiViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemSubject.send(indexPath.item)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemCount = dataSource?.snapshot().itemIdentifiers.count,
              itemCount > .zero
        else {
            return
        }
        
        if indexPath.item >= itemCount - 5 {
            willDisplayLastItemSubject.send()
        }
    }
}


// MARK: - Setup Method

private extension ActivityNotiViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            collectionView,
            emptyLabel
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupDataSource() {
        let profileInteractionTypes = TriggerType.ActivityNotification.profileInteractionTypes
        
        let cellRegistration = CellRegistration<NotificationCell, Item> { cell, indexPath, item in
            let content = item.targetContentText.isEmpty
            ? item.message
            : "\(item.message)\n : \(item.targetContentText.truncated(toLength: 15))"
            
            let time = item.time ?? .now
            
            cell.configure(imageURL: item.triggerUserProfileURL, content: content, time: time.elapsedText)
            
            if let triggerType = item.type,
               profileInteractionTypes.contains(triggerType) {
                cell.profileImageViewDidTapAction = { [weak self] in
                    self?.profileImageViewDidTapSubject.send(indexPath.item)
                }
            }
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func setupAction() {
        collectionView.refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
    }
    
    func setupDelegate() {
        collectionView.delegate = self
    }
}

// MARK: - Helper Method

private extension ActivityNotiViewController {
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapshot)
    }
}

// MARK: - Action Method

private extension ActivityNotiViewController {
    @objc func collectionViewDidRefresh() {
        didRefreshSubject.send()
    }
}

// MARK: - Computed Property

private extension ActivityNotiViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
