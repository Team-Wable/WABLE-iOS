//
//  GameScheduleListViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import Combine
import UIKit

import SnapKit
import Then

final class GameScheduleListViewController: UIViewController {
    
    // MARK: - Section & Item
    
    enum Section: Hashable {
        case gameType
        case gameSchedule(Date)
    }
    
    enum Item: Hashable {
        case gameType(String)
        case game(Game)
    }
    
    // MARK: - typealias

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = GameScheduleViewModel

    // MARK: - UIComponent

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let emptyImageView = UIImageView(image: .imgNotiEmpty).then {
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let didLoadSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupCollectionViewLayout()
        setupDataSource()
        setupAction()
        setupBinding()
        
        didLoadSubject.send()
    }
}

// MARK: - Setup Method

private extension GameScheduleListViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            collectionView,
            emptyImageView
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.adjustedWidthEqualTo(200)
            make.adjustedHeightEqualTo(188)
        }
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case .zero:
                return self?.gameTypeSection
            default:
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
        
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "MM.dd (E)"
            $0.locale = Locale(identifier: "ko_KR")
        }
        let nowText = dateFormatter.string(from: Date())
        
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
            case .gameSchedule(let date):
                let dateText = dateFormatter.string(from: date)
                headerView.configure(isToday: dateText == nowText, date: dateText)
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
                  indexPath.section != .zero
            else {
                return nil
            }
            
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    func setupAction() {
        collectionView.refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            viewDidLoad: didLoadSubject.eraseToAnyPublisher(),
            viewDidRefresh: didRefreshSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.item
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.applySnapshot(item: item)
                self?.emptyImageView.isHidden = !item.isEmpty
            }
            .store(in: cancelBag)
        
        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard !isLoading else { return }
                self?.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Method

private extension GameScheduleListViewController {
    func applySnapshot(item: GameScheduleViewItem) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.gameType])
        snapshot.appendItems([.gameType(item.gameType)], toSection: .gameType)
        
        for gameSchedule in item.gameSchedules {
            guard let date = gameSchedule.date else {
                continue
            }
            
            let section = Section.gameSchedule(date)
            snapshot.appendSections([section])
            let games = gameSchedule.games.map { Item.game($0) }
            snapshot.appendItems(games, toSection: section)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Action Method

private extension GameScheduleListViewController {
    @objc func collectionViewDidRefresh() {
        didRefreshSubject.send()
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
            heightDimension: .absolute(40.adjustedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 20, leading: 16, bottom: 20, trailing: 16)
        
        return section
    }
    
    var gameScheduleSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100.adjustedHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 36, trailing: 16)
        section.interGroupSpacing = 16
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(28.adjustedHeight)
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
