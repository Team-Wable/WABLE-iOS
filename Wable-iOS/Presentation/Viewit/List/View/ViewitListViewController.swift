//
//  ViewitListViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//

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
    
    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let didLoadRelay = PassthroughRelay<Void>()
    private let meatballRelay = PassthroughRelay<Int>()
    private let likeRelay = PassthroughRelay<Int>()
    private let willLastDisplayRelay = PassthroughRelay<Void>()
    private let bottomSheetActionRelay = PassthroughRelay<ViewitBottomSheetActionKind>()
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

// MARK: - Setup Method

private extension ViewitListViewController {
    func setupDataSource() {
        let cellRegistration = CellRegistration<ViewitListCell, Item> { cell, indexPath, item in
            cell.configure(
                profileImageURL: item.userProfileURL,
                userName: item.userNickname,
                description: item.text,
                thumbnailImageURL: item.thumbnailURL,
                title: item.title,
                siteName: item.siteName,
                isLiked: item.like.status,
                likeCount: item.like.count,
                isBlind: item.status == .blind
            )
            
            cell.profileInfoDidTapClosure = { [weak self] in
                WableLogger.log("프로필 정보 눌림", for: .debug)
                
                self?.profileDidTapRelay.send(item.userID)
            }
            
            cell.meatballDidTapClosure = { [weak self] in
                self?.meatballRelay.send(item.id)
            }
            
            cell.cardDidTapClosure = {
                guard let url = item.siteURL,
                      UIApplication.shared.canOpenURL(url)
                else {
                    return WableLogger.log("사이트를 열 수 없습니다: \(item.siteURL?.absoluteString ?? "")", for: .error)
                }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        createButton.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
        refreshControl?.addTarget(self, action: #selector(viewDidRefresh), for: .valueChanged)
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
            bottomSheetAction: bottomSheetActionRelay.eraseToAnyPublisher(),
            profileDidTap: profileDidTapRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.isLoading
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.refreshControl?.endRefreshing()
            }
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
            .sink { [weak self] role in
                self?.presentBottomSheet(for: role)
            }
            .store(in: cancelBag)
        
        output.isReportSuccess
            .filter { $0 }
            .sink { _ in ToastView(status: .complete, message: Constant.reportSuccessMessage).show() }
            .store(in: cancelBag)
        
        output.moveToProfile
            .sink { [weak self] userID in
                switch userID {
                case .some(let value):
                    self?.navigateToOtherProfile(for: value)
                case .none:
                    self?.showMyProfile()
                }
            }
            .store(in: cancelBag)
        
        output.errorMessage
            .sink { [weak self] message in
                let alertController = UIAlertController(
                    title: "오류가 발생했어요.",
                    message: message,
                    preferredStyle: .alert
                )
                let confirmAction = UIAlertAction(title: "확인", style: .default)
                alertController.addAction(confirmAction)
                self?.present(alertController, animated: true)
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
        let bottomSheet = WableBottomSheetController()
        
        switch userRole {
        case .admin:
            let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                self?.presentActionSheet(for: .report)
            }
            let banAction = WableBottomSheetAction(title: "밴하기") { [weak self] in
                self?.presentActionSheet(for: .ban)
            }
            bottomSheet.addActions(reportAction, banAction)
        case .owner:
            let deleteAction = WableBottomSheetAction(title: "삭제하기") { [weak self] in
                self?.presentActionSheet(for: .delete)
            }
            bottomSheet.addAction(deleteAction)
        case .viewer:
            let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                self?.presentActionSheet(for: .report)
            }
            bottomSheet.addAction(reportAction)
        }
        
        present(bottomSheet, animated: true)
    }
    
    func presentActionSheet(for action: ViewitBottomSheetActionKind) {
        let title: String
        let message: String
        let buttonTitle: String
        
        switch action {
        case .report:
            title = Constant.Report.title
            message = Constant.Report.message
            buttonTitle = Constant.Report.buttonTitle
        case .delete:
            title = Constant.Delete.title
            message = Constant.Delete.message
            buttonTitle = Constant.Delete.buttonTitle
        case .ban:
            title = Constant.Ban.title
            message = StringLiterals.Ban.sheetMessage
            buttonTitle = Constant.Ban.buttonTitle
        }
        
        let cancelAction = WableSheetAction(title: Constant.cancelButtonTitle, style: .gray)
        let primaryAction = WableSheetAction(title: buttonTitle, style: .primary) { [weak self] in
            self?.bottomSheetActionRelay.send(action)
        }
        
        let wableSheet = WableSheetViewController(title: title, message: message).then {
            $0.addActions(cancelAction, primaryAction)
        }
        present(wableSheet, animated: true)
    }
    
    func showMyProfile() {
        let myProfileTabIndex = 4
        navigationController?.tabBarController?.selectedIndex = myProfileTabIndex
    }
    
    func navigateToOtherProfile(for userID: Int) {
        let otherProfileViewController = OtherProfileViewController(
            viewModel: .init(
                userID: userID,
                fetchUserProfileUseCase: FetchUserProfileUseCaseImpl(),
                checkUserRoleUseCase: CheckUserRoleUseCaseImpl(
                    repository: UserSessionRepositoryImpl(
                        userDefaults: UserDefaultsStorage(
                            jsonEncoder: JSONEncoder(),
                            jsonDecoder: JSONDecoder()
                        )
                    )
                )
            )
        )
        
        navigationController?.pushViewController(otherProfileViewController, animated: true)
    }
    
    // MARK: - Action Method

    @objc func createButtonDidTap() {
        let useCase = CreateViewitUseCaseImpl()
        let writeViewController = CreateViewitViewController(viewModel: .init(useCase: useCase))
        writeViewController.delegate = self
        present(writeViewController, animated: true)
    }
    
    @objc func viewDidRefresh() {
        didLoadRelay.send()
    }
    
    // MARK: - Computed Property
    
    var collectionView: UICollectionView { rootView.collectionView }
    var refreshControl: UIRefreshControl? { rootView.collectionView.refreshControl }
    var createButton: UIButton { rootView.createButton }
    
    // MARK: - Constant

    enum Constant {
        enum Report {
            static let title = "신고하시겠어요?"
            static let message = "해당 유저 혹은 게시글을 신고하시려면\n신고하기 버튼을 눌러주세요."
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
        
        static let cancelButtonTitle = "취소"
        static let reportSuccessMessage = """
                                        신고 접수가 완료되었어요.
                                        24시간 내에 조치할 예정이에요.
                                        """
    }
}
