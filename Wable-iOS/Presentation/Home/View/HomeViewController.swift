//
//  HomeViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import Combine
import UIKit

final class HomeViewController: NavigationViewController {

    // MARK: - Section
    
    enum Section: Hashable {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = Content
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    private let viewModel: HomeViewModel
    private let willAppearSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let didSelectedSubject = PassthroughSubject<Int, Never>()
    private let didHeartTappedSubject = PassthroughSubject<Bool, Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let cancelBag: CancelBag
    
    // MARK: - UIComponent
    
    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private lazy var plusButton: UIButton = .init(configuration: .plain()).then {
        $0.configuration?.image = .btnWrite
    }
    
    private let emptyLabel: UILabel = UILabel().then {
        $0.attributedText = "아직 작성된 글이 없어요.".pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.isHidden = true
    }
    
    // MARK: - LifeCycle
    
    init(viewModel: HomeViewModel, cancelBag: CancelBag) {
        self.viewModel = viewModel
        self.cancelBag = cancelBag
        
        // TODO: 알림 여부 판단해서 넣어주는 로직 필요
        super.init(type: .home(hasNewNotification: false))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDataSource()
        setupAction()
        setupDelegate()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        willAppearSubject.send()
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectedSubject.send(indexPath.item)
    }
    
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
        
        if indexPath.item >= itemCount - 5 {
            willDisplayLastItemSubject.send()
        }
    }
}


// MARK: - Setup Method

private extension HomeViewController {
    func setupView() {
        navigationController?.navigationBar.isHidden = true
        
        view.addSubviews(
            collectionView,
            plusButton,
            emptyLabel
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(16)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setupDataSource() {
        let homeCellRegistration = CellRegistration<ContentCollectionViewCell, Content> { cell, indexPath, itemID in
            cell.configureCell(info: itemID.content.contentInfo, postType: .mine)
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: homeCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func setupAction() {
        collectionView.refreshControl?.addAction(UIAction(handler: { [weak self] _ in
            self?.didRefreshSubject.send()
        }), for: .valueChanged)
        plusButton.addTarget(self, action: #selector(plusButtonDidTap), for: .touchUpInside)
    }
    
    func setupDelegate() {
        collectionView.delegate = self
    }
    
    func setupBinding() {
        let input = HomeViewModel.Input(
            viewWillAppear: willAppearSubject.eraseToAnyPublisher(),
            viewDidRefresh: didRefreshSubject.eraseToAnyPublisher(),
            didSelectedItem: didSelectedSubject.eraseToAnyPublisher(),
            didHeartTappedItem: didHeartTappedSubject.eraseToAnyPublisher(),
            willDisplayLastItem: willDisplayLastItemSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.contents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contents in
                self?.applySnapshot(items: contents)
                self?.emptyLabel.isHidden = !contents.isEmpty
            }
            .store(in: cancelBag)
        
        output.selectedContent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                let viewController = HomeDetailViewController(type: .page(type: .detail, title: content.content.contentInfo.title))
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            .store(in: cancelBag)
        
        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Method

private extension HomeViewController {
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapshot)
    }
}

// MARK: - Action Method

private extension HomeViewController {
    @objc func plusButtonDidTap() {
        let viewController = WritePostViewController(
            viewModel: WritePostViewModel(
                createContentUseCase: CreateContentUseCase(
                    repository: ContentRepositoryImpl()
                )
            )
        )
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Computed Property

private extension HomeViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(500)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(500)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
