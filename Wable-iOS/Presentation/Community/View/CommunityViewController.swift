//
//  CommunityViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import Combine
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
    private let registerSubject = PassthroughSubject<Int, Never>()
    private let checkNotificationAuthorizationSubject = PassthroughSubject<Void, Never>()
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
    }
}

private extension CommunityViewController {
    
    // MARK: - Setup Method
    
    func setupAction() {
        rootView.askDidTap
            .compactMap { URL(string: StringLiterals.URL.feedbackForm) }
            .sink { [weak self] url in
                self?.present(SFSafariViewController(url: url), animated: true)
            }
            .store(in: cancelBag)
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
            
            let progress = Float(item.community.registrationRate) / Float(100)
            
            cell.configure(
                image: UIImage(named: teamName.lowercased()),
                title: teamName,
                progress: progress,
                progressBarColor: UIColor(named: "\(teamName.lowercased())50") ?? .purple50
            )
            
            cell.copyLinkClosure = { [weak self] in
                self?.showCopyLinkCompleteSheet()
                self?.copyLinkToClipboard()
            }
        }
        
        let headerKind = UICollectionView.elementKindSectionHeader
        let headerRegistration = SupplementaryRegistration<CommunityHeaderView>(elementKind: headerKind) { _, _, _ in }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
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
            refresh: rootView.didRefresh,
            register: registerSubject.eraseToAnyPublisher(),
            checkNotificationAuthorization: checkNotificationAuthorizationSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.communityItems
            .sink { [weak self] in self?.applySnapshot(items: $0) }
            .store(in: cancelBag)
        
        output.isLoading
            .filter { !$0 }
            .sink { [weak self] _ in self?.rootView.refreshControl.endRefreshing() }
            .store(in: cancelBag)
        
        output.registrationCompleted
            .compactMap { $0 }
            .sink { [weak self] team in
                self?.scrollToTop()
                self?.showCompleteSheet(for: team.rawValue)
            }
            .store(in: cancelBag)
        
        output.isNotificationAuthorized
            .filter { !$0 }
            .sink { [weak self] _ in self?.showAlarmSettingSheet() }
            .store(in: cancelBag)
    }
    
    // MARK: - Helper Method

    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func showRegisterSheet(for item: Int) {
        let wableSheet = WableSheetViewController(
            title: StringLiterals.Community.registerSheetTitle,
            message: StringLiterals.Community.registerSheetMessage
        )
        
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let registerAction = WableSheetAction(title: "신청하기", style: .primary) { [weak self] in
            AmplitudeManager.shared.trackEvent(tag: .clickApplyTeamzone)
            
            self?.registerSubject.send(item)
        }
        wableSheet.addActions(cancelAction, registerAction)
        present(wableSheet, animated: true)
    }
    
    func showCompleteSheet(for teamName: String) {
        let completeSheet = CommunityRegisterCompleteViewController(teamName: teamName)
        present(completeSheet, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completeSheet.dismiss(animated: true) { [weak self] in
                self?.checkNotificationAuthorizationSubject.send()
            }
        }
    }
    
    func showAlarmSettingSheet() {
        let wableSheet = WableSheetViewController(
            title: StringLiterals.Community.alarmSheetTitle,
            message: StringLiterals.Community.alarmSheetMessage
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
            title: StringLiterals.Community.inviteSheetTitle,
            message: StringLiterals.Community.inviteSheetMessage
        )
        
        let primaryAction = WableSheetAction(title: "좋아요!", style: .primary)
        wableSheet.addActions(primaryAction)
        
        present(wableSheet, animated: true)
    }
    
    func copyLinkToClipboard() {
        UIPasteboard.general.string = StringLiterals.URL.littly
    }
    
    func scrollToTop() {
        rootView.collectionView.setContentOffset(.zero, animated: true)
    }
}
