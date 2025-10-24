//
//  AccountInfoViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import UIKit
import SafariServices

import SnapKit
import Then

final class AccountInfoViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    // MARK: - Typealias
    
    typealias Item = AccountInfoCellItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - UIComponent
    
    private let navigationView = NavigationView(type: .page(type: .detail, title: "계정 정보"))

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.isScrollEnabled = false
    }
    
    private let withdrawButton = UIButton().then {
        $0.setTitle("계정 삭제하기", for: .normal)
        $0.setTitleColor(.error, for: .normal)
    }
    
    // MARK: - Property
    
    var showWithdrawalReason: (() -> Void)?
    
    private var dataSource: DataSource?
    
    private let viewModel: AccountInfoViewModel
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer
    
    init(viewModel: AccountInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        setupAction()
        setupDataSource()
        setupBinding()
        
        viewModel.viewDidLoad()
    }
}

private extension AccountInfoViewController {
    
    // MARK: - Setup Method

    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(navigationView, collectionView, withdrawButton)
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(withdrawButton.snp.top)
        }
        
        withdrawButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea).offset(-12)
            make.adjustedHeightEqualTo(52)
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupAction() {
        navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        withdrawButton.addTarget(self, action: #selector(withdrawButtonDidTap), for: .touchUpInside)
    }
    
    func setupDataSource() {
        let cellRegistration = CellRegistration<AccountInfoCell, Item> { cell, indexPath, item in
            guard item.isUserInteractive else {
                cell.configure(title: item.title, description: item.description)
                return
            }
            
            cell.configure(title: item.title, description: item.description) { [weak self] in
                guard let url = URL(string: StringLiterals.URL.terms) else { return }
                let safari = SFSafariViewController(url: url)
                self?.present(safari, animated: true)
            }
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    func setupBinding() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.applySnapshot(items: $0) }
            .store(in: cancelBag)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                let alert = UIAlertController(title: "에러가 발생했습니다.", message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Action Method

    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func withdrawButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickDeleteAccount)
        
        showWithdrawalReason?()
    }
    
    // MARK: - Helper Method
    
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot)
    }

    // MARK: - Computed Property

    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(52.adjustedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(52.adjustedHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
