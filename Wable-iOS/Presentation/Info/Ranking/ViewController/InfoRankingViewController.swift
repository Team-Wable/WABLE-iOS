//
//  InfoRankingViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit
import Combine
import SafariServices

import CombineCocoa

final class InfoRankingViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Item: Hashable {
        case session(String)
        case rank(LCKTeamRankDTO)
    }
    
    enum Section: CaseIterable {
        case session
        case rank
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let viewModel: InfoRankingViewModel
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    private let rootView = RankingView()
    
    // MARK: - Initializer
    
    init(viewModel: InfoRankingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDataSource()
        setupAction()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearSubject.send(())
    }
}

// MARK: - Private Method

private extension InfoRankingViewController {
    func setupCollectionView() {
        rootView.collectionView.setCollectionViewLayout(collectionViewLayout, animated: false)
        
        rootView.collectionView.register(
            RankHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RankHeaderView.identifier
        )
    }
    
    func setupDataSource() {
        let rankCellRegistration = UICollectionView.CellRegistration<RankCell, LCKTeamRankDTO> {
            cell, indexPath, item in
            let teamRankItem = TeamRankMapper(rawValue: item.teamName)
            cell.rankLabel.text = "\(item.teamRankNumber)"
            cell.rankLabel.textColor = teamRankItem?.lckCupTeam.color
            cell.teamLogoImageView.image = TeamRankMapper(rawValue: item.teamName)?.image
            cell.teamNameLabel.text = item.teamName
            cell.winCountLabel.text = "\(item.teamWinCount)"
            cell.defeatCountLabel.text = "\(item.teamDefeatCount)"
            cell.winningRateLabel.text = "\(item.winningRate)%"
            cell.scoreDiffLabel.text = "\(item.scoreDiff)"
        }
        
        let sessionCellRegistration = UICollectionView.CellRegistration<SessionCell, String> { cell, indexPath, item in
            cell.titleLabel.text = item
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            switch item {
            case .session(let gameType):
                collectionView.dequeueConfiguredReusableCell(
                    using: sessionCellRegistration,
                    for: indexPath,
                    item: gameType
                )
            case .rank(let teamRank):
                collectionView.dequeueConfiguredReusableCell(
                    using: rankCellRegistration,
                    for: indexPath,
                    item: teamRank
                )
            }
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  indexPath.section == Section.allCases.firstIndex(of: .rank),
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RankHeaderView.identifier,
                    for: indexPath
                  ) as? RankHeaderView
            else {
                return nil
            }
            return header
        }
    }
    
    func applySnapshot(items: [Item], to section: Section) {
        var snapshot = dataSource?.snapshot() ?? Snapshot()
        
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections(Section.allCases)
        }
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setupAction() {
        rootView.submitOpinionButton.tapPublisher
            .compactMap { _ in URL(string: StringLiterals.Info.submitOpinionURL) }
            .sink { [weak self] url in
                let safariViewController = SFSafariViewController(url: url)
                self?.present(safariViewController, animated: true)
            }
            .store(in: cancelBag)
    }
    
    func setupBinding() {
        let input = InfoRankingViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.gameType
            .receive(on: RunLoop.main)
            .map { Item.session($0.lckGameType) }
            .sink { [weak self] item in
                self?.applySnapshot(items: [item], to: .session)
            }
            .store(in: cancelBag)
        
        output.teamRanks
            .receive(on: RunLoop.main)
            .map { ranks in
                ranks.map { Item.rank($0) }
            }
            .sink { [weak self] items in
                self?.applySnapshot(items: items, to: .rank)
            }
            .store(in: cancelBag)
    }
}

private extension InfoRankingViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40.adjustedH)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40.adjustedH)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            let sectionKind = Section.allCases[sectionIndex]
            switch sectionKind {
            case .session:
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
                
            case .rank:
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(36.adjusted)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
    }
}
