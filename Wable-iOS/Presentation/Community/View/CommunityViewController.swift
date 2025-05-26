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
    private let checkNotificationAuthorizationRelay = PassthroughRelay<Void>()
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
                self?.showRegisterSheet(for: indexPath.item)
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
            
            cell.copyLinkClosure = { [weak self] in
                self?.showCopyLinkCompleteSheet()
                self?.copyLinkToClipboard()
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
            register: registerRelay.eraseToAnyPublisher(),
            checkNotificationAuthorization: checkNotificationAuthorizationRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.communityItems
            .sink { [weak self] communityItems in
                WableLogger.log("커뮤니티 아이템: \(communityItems)", for: .debug)
                self?.applySnapshot(items: communityItems)
            }
            .store(in: cancelBag)
        
        output.isLoading
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.refreshControl?.endRefreshing()
            }
            .store(in: cancelBag)
        
        output.completeRegistration
            .compactMap { $0 }
            .sink { [weak self] team in
                self?.scrollToTopItem()
                self?.showCompleteSheet(for: team.rawValue)
            }
            .store(in: cancelBag)
        
        output.isNotificationAuthorized
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.showAlarmSettingSheet()
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
    
    func showRegisterSheet(for item: Int) {
        let wableSheet = WableSheetViewController(
            title: Constant.registerSheetTitle,
            message: Constant.registerSheetMessage
        )
        
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let registerAction = WableSheetAction(title: "신청하기", style: .primary) { [weak self] in
            self?.registerRelay.send(item)
        }
        wableSheet.addActions(cancelAction, registerAction)
        present(wableSheet, animated: true)
    }
    
    func showCompleteSheet(for teamName: String) {
        let completeSheet = CommunityRegisterCompleteViewController(teamName: teamName)
        present(completeSheet, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completeSheet.dismiss(animated: true) { [weak self] in
                self?.checkNotificationAuthorizationRelay.send()
            }
        }
    }
    
    func showAlarmSettingSheet() {
        let wableSheet = WableSheetViewController(
            title: Constant.pushAlarmSettingSheetTitle,
            message: Constant.pushAlarmSettingSheetMessage
        )
        
        let cancelAction = WableSheetAction(title: "나중에", style: .gray)
        let pushAlarmSettingAction = WableSheetAction(title: "푸시알람 설정", style: .primary) {
            guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingURL)
            else {
                return WableLogger.log("설정 창을 열 수 없습니다!", for: .error)
            }
            UIApplication.shared.open(settingURL)
        }
        wableSheet.addActions(cancelAction, pushAlarmSettingAction)
        
        present(wableSheet, animated: true)
    }
    
    func showCopyLinkCompleteSheet() {
        let wableSheet = WableSheetViewController(
            title: Constant.copyLinkCompleteSheetTitle,
            message: Constant.copyLinkCompleteSheetMessage
        )
        
        let primaryAction = WableSheetAction(title: "좋아요!", style: .primary)
        wableSheet.addActions(primaryAction)
        
        present(wableSheet, animated: true)
    }
    
    func copyLinkToClipboard() {
        UIPasteboard.general.string = StringLiterals.URL.littly
    }
    
    func scrollToTopItem() {
        guard collectionView.numberOfSections > 0,
                collectionView.numberOfItems(inSection: 0) > 0
        else {
            return
        }
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}

// MARK: - Action Method

private extension CommunityViewController {
    @objc func askButtonDidTap() {
        guard let url = URL(string: StringLiterals.URL.feedbackForm) else { return }
        
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
        static let registerSheetTitle = "사전 신청하시겠어요?"
        static let registerSheetMessage = "1개의 팀별 공간에만 참여가 가능하다는 점\n꼭 기억해주세요!"
        static let pushAlarmSettingSheetTitle = "푸시 알림 안내"
        static let pushAlarmSettingSheetMessage = "푸시 알림을 켜두면 팀별 커뮤니티가\n오픈됐을 때 알림으로 안내드려요!"
        static let copyLinkCompleteSheetTitle = "링크가 복사되었어요"
        static let copyLinkCompleteSheetMessage = "복사된 링크를 널리널리 퍼뜨려\n함께 응원할 팬을 더 많이 데려와주세요!"
    }
}
