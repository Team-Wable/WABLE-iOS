//
//  InfoRankingViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit
import Combine

final class InfoRankingViewController: UIViewController {
    
    typealias Item = LCKTeamRankDTO
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section {
        case main
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
        
        setupDataSource()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearSubject.send(())
    }
}

// MARK: - Private Method

private extension InfoRankingViewController {
    func setupDataSource() {
        let rankCellRegistration = UICollectionView.CellRegistration<RankCell, LCKTeamRankDTO> {
            cell, indexPath, item in
            cell.rankLabel.text = "\(item.teamRankNumber)"
            cell.teamLogoImageView.image = TeamImageMapper(rawValue: item.teamName)?.image
            cell.teamNameLabel.text = item.teamName
            cell.winCountLabel.text = "\(item.teamWinCount)"
            cell.defeatCountLabel.text = "\(item.teamDefeatCount)"
            cell.winningRateLabel.text = "\(item.winningRate)%"
            cell.scoreDiffLabel.text = "\(item.scoreDiff)"
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: rankCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func applySnapshot(items: [Item], to section: Section) {
        var snapshot = dataSource?.snapshot() ?? Snapshot()
        
        if snapshot.sectionIdentifiers.contains(section) {
            snapshot.deleteSections([section])
        }
        
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot)
    }
    
    func setupBinding() {
        let input = InfoRankingViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.gameType
            .receive(on: RunLoop.main)
            .sink { [weak self] gameType in
                self?.rootView.sessionLabel.text = gameType.lckGameType
            }
            .store(in: cancelBag)
        
        output.teamRanks
            .receive(on: RunLoop.main)
            .sink { [weak self] ranks in
                self?.applySnapshot(items: ranks, to: .main)
            }
            .store(in: cancelBag)
    }
}
