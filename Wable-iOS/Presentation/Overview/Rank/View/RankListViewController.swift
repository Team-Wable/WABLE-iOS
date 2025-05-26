//
//  RankListViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import Combine
import UIKit
import SafariServices

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
    
    // MARK: - typealias

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = RankViewModel
    
    // MARK: - UIComponent

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.refreshControl = UIRefreshControl()
    }
    
    private let submitButton = WableButton(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = Constant.submitButtonTitle.pretendardString(with: .body3)
            .highlight(textColor: .sky50, to: "의견 남기러 가기")
        $0.configuration = config
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let viewModel: ViewModel

    private let didLoadRelay = PassthroughRelay<Void>()
    private let didRefreshRelay = PassthroughRelay<Void>()
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
        setupAction()
        setupColletionViewLayout()
        setupDataSource()
        setupBinding()
        
        didLoadRelay.send()
    }
}

// MARK: - Setup Method

private extension RankListViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            collectionView,
            submitButton
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.adjustedHeightEqualTo(48)
        }
    }
    
    func setupAction() {
        submitButton.publisher(for: .touchUpInside)
            .compactMap { _ in URL(string: Constant.googleFormURLText) }
            .sink { [weak self] url in
                let safariViewController = SFSafariViewController(url: url)
                self?.present(safariViewController, animated: true)
            }
            .store(in: cancelBag)
        
        collectionView.refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
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
    
    func setupBinding() {
        let input = ViewModel.Input(
            viewDidLoad: didLoadRelay.eraseToAnyPublisher(),
            viewDidRefresh: didRefreshRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.item
            .sink { [weak self] item in
                self?.applySnapshot(item: item)
            }
            .store(in: cancelBag)
        
        output.isLoading
            .sink { [weak self] isLoading in
                guard !isLoading else { return }
                self?.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Method

private extension RankListViewController {
    func applySnapshot(item: RankViewItem) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.gameType])
        snapshot.appendItems([.gameType(item.gameType)], toSection: .gameType)
        
        snapshot.appendSections([.rank])
        let ranks = item.ranks.map { Item.rank($0) }
        snapshot.appendItems(ranks, toSection: .rank)
        
        dataSource?.apply(snapshot)
    }
}

// MARK: - Action Method

private extension RankListViewController {
    @objc func collectionViewDidRefresh() {
        didRefreshRelay.send()
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
        section.contentInsets = .init(top: 20, leading: 16, bottom: 12, trailing: 16)
        
        return section
    }
    
    var rankSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(40.adjustedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(40)
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
