//
//  CommunityViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit
import SafariServices

import SnapKit
import Then

final class CommunityViewController: UIViewController {
    
    // MARK: - Section & Item

    enum Section {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = CommunityItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = CommunityViewModel

    // MARK: - UIComponent
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let askButton = WableButton(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = Constant.askButtonTitle
            .pretendardString(with: .body3)
            .highlight(textColor: .sky50, to: "요청하기")
        $0.configuration = config
    }
    
    // MARK: - Property

    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let viewDidLoadRelay = PassthroughRelay<Void>()
    private let viewDidRefreshRelay = PassthroughRelay<Void>()
    private let registerRelay = PassthroughRelay<Int>()
    private let copyLinkRelay = PassthroughRelay<Void>()
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
        setupAction()
        setupNavigationBar()
        setupDataSource()
        setupBinding()
        
        viewDidLoadRelay.send()
    }
}

// MARK: - Setup Method

private extension CommunityViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        let statusBarBackgroundView = UIView(backgroundColor: .wableBlack)
        
        let navigationView = NavigationView(type: .hub(title: "커뮤니티", isBeta: true)).then {
            $0.configureView()
        }
        
        let underlineView = UIView(backgroundColor: .gray200)
        
        view.addSubviews(
            statusBarBackgroundView,
            navigationView,
            collectionView,
            askButton,
            underlineView
        )
        
        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(60)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        askButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(safeArea).offset(-16)
            make.adjustedHeightEqualTo(48)
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(1)
        }
    }
    
    func setupAction() {
        askButton.addTarget(self, action: #selector(askButtonDidTap), for: .touchUpInside)
        
        collectionView.refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupDataSource() {
        let registerCellRegistration = CellRegistration<CommunityRegisterCell, Item> { cell, indexPath, item in
            let teamName = item.community.team?.rawValue ?? ""
            
            cell.configure(
                image: UIImage(named: teamName.lowercased()),
                title: teamName,
                isRegistered: item.isRegistered
            )
            
            cell.registerCommunityClosure = { [weak self] in
                WableLogger.log("셀 눌림: \(indexPath.item)", for: .debug)
                self?.registerRelay.send(indexPath.item)
            }
        }
        
        let inviteCellRegistration = CellRegistration<CommunityInviteCell, Item> { cell, indexPath, item in
            let teamName = item.community.team?.rawValue ?? ""
            
            cell.configure(
                image: UIImage(named: teamName.lowercased()),
                title: teamName,
                progress: Float(item.community.registrationRate),
                progressBarColor: UIColor(named: "\(teamName.lowercased())50") ?? .purple50
            )
            
            cell.copyLinkClosure = {
                WableLogger.log("링크 복사 버튼 눌림", for: .debug)
            }
        }
        
        let headerKind = UICollectionView.elementKindSectionHeader
        let headerRegistration = SupplementaryRegistration<CommunityHeaderView>(elementKind: headerKind) { _, _, _ in }
        
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let communityRegistration = self?.viewModel.registration else {
                return nil
            }
            
            if communityRegistration.hasRegisteredTeam,
                item.isRegistered {
                return collectionView.dequeueConfiguredReusableCell(
                    using: inviteCellRegistration,
                    for: indexPath,
                    item: item
                )
            }
            
            return collectionView.dequeueConfiguredReusableCell(
                using: registerCellRegistration,
                for: indexPath,
                item: item
            )
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == headerKind else {
                return nil
            }
            
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            viewDidLoad: viewDidLoadRelay.eraseToAnyPublisher(),
            viewDidRefresh: viewDidRefreshRelay.eraseToAnyPublisher(),
            register: registerRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.communityItems
            .sink { [weak self] communityItems in
                self?.applySnapshot(items: communityItems)
            }
            .store(in: cancelBag)
        
        output.isLoading
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Method

private extension CommunityViewController {
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Action Method

private extension CommunityViewController {
    @objc func askButtonDidTap() {
        guard let url = URL(string: Constant.googleFormURLText) else { return }
        
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true)
    }
    
    @objc func collectionViewDidRefresh() {
        viewDidRefreshRelay.send()
    }
}

// MARK: - Computed Property

private extension CommunityViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(96)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(96)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.adjustedHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Constant

private extension CommunityViewController {
    enum Constant {
        static let askButtonTitle = "더 추가하고 싶은 게시판이 있다면? 요청하기"
        static let googleFormURLText = "https://docs.google.com/forms/d/e/1FAIpQLSf3JlBkVRPaPFSreQHaEv-u5pqZWZzk7Y4Qll9lRP0htBZs-Q/viewform"
    }
}
