//
//  GameScheduleListViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import UIKit

import SnapKit
import Then

final class GameScheduleListViewController: UIViewController {
    
    // MARK: - Section & Item
    
    enum Section: Int, CaseIterable {
        case gameType
        case gameSchedule
    }
    
    enum Item: Hashable {
        case gameType(String)
        case game(Game)
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias CellRegistration = UICollectionView.CellRegistration
    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration

    // MARK: - UIComponent

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let emptyView: GameScheduleEmptyView = .init().then {
        $0.isHidden = true
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupCollectionViewLayout()
        setupDataSource()
    }
}

// MARK: - Setup Method

private extension GameScheduleListViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            collectionView,
            emptyView
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            switch section {
            case .gameType:
                return self?.gameTypeSection
            case .gameSchedule:
                return self?.gameScheduleSection
            }
        }
        
        collectionView.collectionViewLayout = layout
    }
    
    func setupDataSource() {
        let gameTypeCellRegistration = CellRegistration<GameTypeCell, String> { cell, indexPath, gameType in
            cell.configure(gameType: gameType)
        }
        
        let gameScheduleCellRegistration = CellRegistration<GameScheduleCell, Game> { cell, indexPath, game in
            let gameTimeFormatter = DateFormatter().then {
                $0.dateFormat = "HH:MM"
            }
            
            let gameStatus = game.status ?? .progress
            let gameTimeText = gameTimeFormatter.string(from: game.date ?? Date())
            
            let homeTeamName = game.homeTeam?.rawValue ?? "TBD"
            let homeTeamLogoImage = UIImage(named: homeTeamName.lowercased())
            
            let awayTeamName = game.awayTeam?.rawValue ?? "TBD"
            let awayTeamLogoImage = UIImage(named: awayTeamName.lowercased())
            
            cell.configure(
                gameStatusImage: gameStatus.image,
                gameTime: gameTimeText,
                homeTeamLogoImage: homeTeamLogoImage,
                homeTeamName: homeTeamName,
                homeTeamScore: game.homeScore,
                awayTeamScore: game.awayScore,
                awayTeamName: awayTeamName,
                awayTeamLogoImage: awayTeamLogoImage
            )
        }
        
        let headerKind = UICollectionView.elementKindSectionHeader
        let headerRegistration = SupplementaryRegistration<GameScheduleHeaderView>(
            elementKind: headerKind
        ) { [weak self] headerView, elementKind, indexPath in
            guard let self,
                  let dataSource
            else {
                return
            }
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .gameType:
                return
            case .gameSchedule:
                //            let gameDateFormatter = DateFormatter().then {
                //                $0.dateFormat = "MM.dd (E)"
                //                $0.locale = Locale(identifier: "ko_KR")
                //            }
                headerView.configure(isToday: true, date: Date().toString())
            }
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .gameType(let type):
                return collectionView.dequeueConfiguredReusableCell(
                    using: gameTypeCellRegistration,
                    for: indexPath,
                    item: type
                )
            case .game(let game):
                return collectionView.dequeueConfiguredReusableCell(
                    using: gameScheduleCellRegistration,
                    for: indexPath,
                    item: game
                )
            }
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == headerKind,
                  let section = Section(rawValue: indexPath.section),
                  section == .gameSchedule
            else {
                return nil
            }
            
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
}

// MARK: - Computed Property

private extension GameScheduleListViewController {
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
    
    var gameScheduleSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 12, leading: 0, bottom: 16, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(40)
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
