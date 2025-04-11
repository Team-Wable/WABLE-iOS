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
    
    // MARK: - Section

    enum Section {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = CommunityItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = CommunityViewModel

    // MARK: - Property

    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let viewDidLoadRelay = PassthroughRelay<Void>()
    private let viewDidRefreshRelay = PassthroughRelay<Void>()
    private let registerRelay = PassthroughRelay<Int>()
    private let copyLinkRelay = PassthroughRelay<Void>()
    private let cancelBag = CancelBag()
    private let rootView = CommunityView()
    
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

    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAction()
        setupNavigationBar()
        setupDataSource()
        setupBinding()
        
        viewDidLoadRelay.send()
    }
}

// MARK: - Setup Method

private extension CommunityViewController {
    func setupAction() {
        askButton.addTarget(self, action: #selector(askButtonDidTap), for: .touchUpInside)
        
        refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupDataSource() {
        let registerCellRegistration = CellRegistration<CommunityRegisterCell, Item> { [weak self] cell, indexPath, item in
            let teamName = item.community.team?.rawValue ?? ""
            
            cell.configure(
                image: UIImage(named: teamName.lowercased()),
                title: teamName,
                hasRegisteredTeam: item.hasRegisteredCommunity
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
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            if item.hasRegisteredCommunity, item.isRegistered {
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
                self?.refreshControl?.endRefreshing()
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
    var collectionView: UICollectionView { rootView.collectionView }
    var refreshControl: UIRefreshControl? { rootView.collectionView.refreshControl }
    var askButton: UIButton { rootView.askButton }
}

// MARK: - Constant

private extension CommunityViewController {
    enum Constant {
        static let googleFormURLText = "https://docs.google.com/forms/d/e/1FAIpQLSf3JlBkVRPaPFSreQHaEv-u5pqZWZzk7Y4Qll9lRP0htBZs-Q/viewform"
    }
}
