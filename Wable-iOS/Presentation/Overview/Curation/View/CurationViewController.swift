//
//  CurationViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/16/25.

import UIKit
import Combine

import SnapKit
import Then

final class CurationViewController: UIViewController {

    // MARK: - Section Enum
    
    private enum Section {
        case main
    }

    // MARK: - Typealias
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, CurationItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CurationItem>

    // MARK: - UIComponents

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CurationViewController.makeLayout()
    ).then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
    }

    private let emptyLabel = UILabel().then {
        $0.attributedText = Constants.emptyDescription.pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.textAlignment = .center
    }
    
    // MARK: - Properties

    private var dataSource: DataSource?

    // MARK: - Life Cycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        setupDataSource()
        applySnapshot()
    }
}

// MARK: - Setup Methods

private extension CurationViewController {
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
    }

    func setupAction() {
        
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CurationCell, CurationItem> { cell, indexPath, item in
            cell.configure(
                time: item.time,
                thumbnailURL: item.thumbnailURL,
                title: item.title,
                source: item.source
            ) {
                UIApplication.shared.open(URL(string: "https://www.naver.com")!)
            }
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

// MARK: - Helper Methods

private extension CurationViewController {
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(CurationItem.mocks, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Constants

private extension CurationViewController {
    enum Constants {
        static let emptyDescription = "아직 추천된 콘텐츠가 없어요."
    }
}

// MARK: - UICollectionViewCompositionalLayout

private extension CurationViewController {
    static func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(256)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(256)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
