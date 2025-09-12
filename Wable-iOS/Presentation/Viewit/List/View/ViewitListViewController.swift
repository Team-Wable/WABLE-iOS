//
//  ViewitListViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//

import Combine
import UIKit
import SafariServices

final class ViewitListViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    // MARK: - Typealias
    
    typealias Item = Viewit
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = ViewitListViewModel
    
    // MARK: - Property
    
    var showCreateViewit: (() -> Void)?
    var showProfile: ((Int?) -> Void)?
    var openURL: ((URL) -> Void)?
    
    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let didLoadRelay = PassthroughRelay<Void>()
    private let meatballRelay = PassthroughRelay<Int>()
    private let likeRelay = PassthroughRelay<Int>()
    private let willLastDisplayRelay = PassthroughRelay<Void>()
    private let reportRelay = PassthroughRelay<String>()
    private let banRelay = PassthroughRelay<Void>()
    private let deleteRelay = PassthroughRelay<Void>()
    private let profileDidTapRelay = PassthroughRelay<Int>()
    private let cancelBag = CancelBag()
    private let rootView = ViewitListView()
    
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
        
        navigationController?.navigationBar.isHidden = true
        
        setupDataSource()
        setupAction()
        setupDelegate()
        setupBinding()
        
        didLoadRelay.send()
    }
}

// MARK: - UICollectionViewDelegate

extension ViewitListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemCount = dataSource?.snapshot().itemIdentifiers.count,
              itemCount > .zero
        else {
            return
        }
        
        if indexPath.item >= itemCount - 2 {
            willLastDisplayRelay.send()
        }
    }
}

// MARK: - CreateViewitViewDelegate

extension ViewitListViewController: CreateViewitViewDelegate {
    func finishCreateViewit() {
        didLoadRelay.send()
    }
}

private extension ViewitListViewController {
    
    // MARK: - Setup Method
    
    func setupDataSource() {
        let cellRegistration = CellRegistration<ViewitListCell, Item> { cell, indexPath, item in
            cell.configure(
                profileImageURL: item.userProfileURL,
                userName: item.userNickname,
                description: item.text,
                thumbnailImageURL: item.thumbnailURL,
                title: item.title,
                siteName: item.siteName,
                isLiked: item.isLiked,
                likeCount: item.likeCount,
                isBlind: item.status == .blind
            )
            
            cell.profileInfoDidTapClosure = { [weak self] in
                WableLogger.log("프로필 정보 눌림", for: .debug)
                
                self?.profileDidTapRelay.send(item.userID)
            }
            
            cell.meatballDidTapClosure = { [weak self] in
                self?.meatballRelay.send(item.id)
            }
            
            cell.cardDidTapClosure = { [weak self] in
                guard let url = item.siteURL else { return }
                self?.openURL?(url)
            }
            
            cell.likeDidTapClosure = { [weak self] in
                self?.likeRelay.send(item.id)
            }
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    func setupAction() {
        rootView.createButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.showCreateViewit?()
            }
            .store(in: cancelBag)
        
        rootView.refreshControl.publisher(for: .valueChanged)
            .sink { [weak self] _ in self?.didLoadRelay.send() }
            .store(in: cancelBag)
    }
    
    func setupDelegate() {
        rootView.collectionView.delegate = self
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            load: didLoadRelay.eraseToAnyPublisher(),
            like: likeRelay.eraseToAnyPublisher(),
            willLastDisplay: willLastDisplayRelay.eraseToAnyPublisher(),
            meatball: meatballRelay.eraseToAnyPublisher(),
            report: reportRelay.eraseToAnyPublisher(),
            delete: deleteRelay.eraseToAnyPublisher(),
            ban: banRelay.eraseToAnyPublisher(),
            profileDidTap: profileDidTapRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.isLoading
            .filter { !$0 }
            .sink { [weak self] _ in self?.rootView.refreshControl.endRefreshing() }
            .store(in: cancelBag)
        
        output.viewitList
            .sink { [weak self] items in
                self?.rootView.emptyLabel.isHidden = !items.isEmpty
                self?.applySnapshot(items: items)
            }
            .store(in: cancelBag)
        
        output.isMoreLoading
            .sink { [weak self] isMoreLoading in
                let loadingIndicator = self?.rootView.loadingIndicator
                isMoreLoading ? loadingIndicator?.startAnimating() : loadingIndicator?.stopAnimating()
            }
            .store(in: cancelBag)
        
        output.userRole
            .sink { [weak self] in self?.presentBottomSheet(for: $0) }
            .store(in: cancelBag)
        
        output.isReportSuccess
            .filter { $0 }
            .sink { _ in ToastView(status: .complete, message: StringLiterals.Report.completeToast).show() }
            .store(in: cancelBag)
        
        output.moveToProfile
            .sink { [weak self] userID in
                self?.showProfile?(userID)
            }
            .store(in: cancelBag)
        
        output.errorMessage
            .sink { [weak self] message in
                let confirmAction = UIAlertAction(title: "확인", style: .default)
                self?.showAlert(title: "오류 발생!", message: message, actions: confirmAction)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Helper Method
    
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot)
    }
    
    func presentBottomSheet(for userRole: UserRole) {
        switch userRole {
        case .admin:
            let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                self?.showReportSheet(onPrimary: { message in
                    self?.reportRelay.send(message ?? "")
                })
            }
            let banAction = WableBottomSheetAction(title: "밴하기") { [weak self] in
                self?.showBanConfirmationSheet()
            }
            showBottomSheet(actions: reportAction, banAction)
        case .owner:
            let deleteAction = WableBottomSheetAction(title: "삭제하기") { [weak self] in
                self?.showDeleteConfirmationSheet()
            }
            showBottomSheet(actions: deleteAction)
        case .viewer:
            let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                self?.showReportSheet(onPrimary: { message in
                    self?.reportRelay.send(message ?? "")
                })
            }
            showBottomSheet(actions: reportAction)
        }
    }
    
    func showDeleteConfirmationSheet() {
        let primaryAction = WableSheetAction(
            title: Constant.Delete.buttonTitle,
            style: .primary
        ) { [weak self] in
            self?.deleteRelay.send()
        }
        showWableSheetWithCancel(
            title: Constant.Delete.title,
            message: Constant.Delete.message,
            action: primaryAction
        )
    }
    
    func showBanConfirmationSheet() {
        let primaryAction = WableSheetAction(
            title: Constant.Ban.buttonTitle,
            style: .primary
        ) { [weak self] in
            self?.banRelay.send()
        }
        showWableSheetWithCancel(
            title: Constant.Ban.title,
            message: StringLiterals.Ban.sheetMessage,
            action: primaryAction
        )
    }
    
    // MARK: - Action Method
    
    @objc func viewDidRefresh() {
        didLoadRelay.send()
    }
    
    // MARK: - Constant

    enum Constant {
        enum Report {
            static let buttonTitle = "신고하기"
        }
        
        enum Ban {
            static let title = "밴하시겠어요?"
            static let buttonTitle = "밴하기"
        }
        
        enum Delete {
            static let title = "삭제하시겠어요?"
            static let message = "게시글이 영구히 삭제됩니다."
            static let buttonTitle = "삭제하기"
        }
    }
}
