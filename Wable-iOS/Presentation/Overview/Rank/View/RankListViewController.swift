//
//  RankListViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import Combine
import UIKit
import SafariServices

import CombineCocoa
import SnapKit
import Then

final class RankListViewController: UIViewController {
    
    // MARK: - Section & Item
    
    enum Section: Int, CaseIterable {
        case gameType
        case rank
    }
    
    enum Item: Hashable {
        case gameType(String)
        case rank(LCKTeamRank)
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias CellRegistration = UICollectionView.CellRegistration
    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration
    
    // MARK: - UIComponent

    private let collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.refreshControl = UIRefreshControl()
    }
    
    private let submitButton: WableButton = .init(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = Constant.submitButtonTitle.pretendardString(with: .body3)
        $0.configuration = config
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let cancelBag: CancelBag = .init()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
        setupColletionViewLayout()
        setupDataSource()
    }
}

// MARK: - Setup Method

private extension RankListViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubview(collectionView)
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func setupAction() {
        submitButton.tapPublisher
            .compactMap { _ in URL(string: Constant.googleFormURLText) }
            .sink { [weak self] url in
                let safariViewController = SFSafariViewController(url: url)
                self?.present(safariViewController, animated: true)
            }
            .store(in: cancelBag)
    }
    
    func setupColletionViewLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            switch section {
            case .gameType:
                return self?.gameTypeSection
            case .rank:
                return self?.rankSection
            }                  
        }
        
        collectionView.collectionViewLayout = layout
    }
    
    func setupDataSource() {
        let gameTypeCellRegistration = CellRegistration<GameTypeCell, String> { cell, indexPath, gameType in
            cell.configure(gameType: gameType)
        }
        
        let rankCellRegistration = CellRegistration<RankCell, LCKTeamRank> { cell, indexPath, rank in
            let teamName = rank.team?.rawValue ?? "TBD"
            cell.configure(
                rank: rank.rank,
                teamLogoImage: UIImage(named: teamName.lowercased()),
                teamName: teamName,
                winCount: rank.winCount,
                defeatCount: rank.defeatCount,
                winningRate: rank.winningRate,
                scoreGap: rank.scoreGap
            )
        }
        
        let headerKind = UICollectionView.elementKindSectionHeader
        let headerRegistration = SupplementaryRegistration<RankHeaderView>(elementKind: headerKind) { _, _, _ in }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .gameType(let gameType):
                return collectionView.dequeueConfiguredReusableCell(
                    using: gameTypeCellRegistration,
                    for: indexPath,
                    item: gameType
                )
                
            case .rank(let rank):
                return collectionView.dequeueConfiguredReusableCell(
                    using: rankCellRegistration,
                    for: indexPath,
                    item: rank
                )
            }
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  indexPath.section == Section.rank.rawValue
            else {
                return nil
            }
            
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
}

// MARK: - Computed Property

private extension RankListViewController {
    var gameTypeSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(40)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 24, leading: 16, bottom: 20, trailing: 16)
        
        return section
    }
    
    var rankSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(40)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(4)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(36)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - Constant

private extension RankListViewController {
    enum Constant {
        static let submitButtonTitle: String = "더 알고싶은 정보가 있다면? 의견 남기러 가기"
        static let googleFormURLText: String = "https://docs.google.com/forms/d/e/1FAIpQLSf3JlBkVRPaPFSreQHaEv-u5pqZWZzk7Y4Qll9lRP0htBZs-Q/viewform"
    }
}
