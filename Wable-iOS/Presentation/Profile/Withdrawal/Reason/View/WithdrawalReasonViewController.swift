//
//  WithdrawalReasonViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then

final class WithdrawalReasonViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    // MARK: - Typealias
    
    typealias Item = WithdrawalReasonCellItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - UIComponent
    
    private let navigationView = NavigationView(type: .page(type: .detail, title: "계정 삭제"))

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.isScrollEnabled = false
    }
    
    private let nextButton = WableButton(style: .gray).then {
        var configuration = $0.configuration
        configuration?.title = "계속"
        $0.configuration = configuration
        $0.isEnabled = false
    }
    
    // MARK: - Property

    private var dataSource: DataSource?
    
    private let viewModel: WithdrawalReasonViewModel
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer

    init(viewModel: WithdrawalReasonViewModel) {
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
        setupNavigationBar()
        setupDataSource()
        setupAction()
        setupBinding()
        
        viewModel.input.load.send()
    }
}

private extension WithdrawalReasonViewController {
    
    // MARK: - Setup

    func setupView() {
        view.backgroundColor = .wableWhite
        
        let titleLabel = UILabel().then {
            $0.attributedText = Constant.title.pretendardString(with: .head0)
            $0.numberOfLines = 0
        }
        
        let descriptionLabel = UILabel().then {
            $0.attributedText = Constant.description.pretendardString(with: .body2)
            $0.numberOfLines = 0
            $0.textColor = .gray600
        }
        
        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel]).then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .leading
            $0.distribution = .fill
        }
        
        view.addSubviews(
            navigationView,
            labelStackView,
            collectionView,
            nextButton
        )
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.leading.equalTo(safeArea).inset(16)
            make.bottom.equalTo(collectionView.snp.top).offset(-32)
        }
        
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(safeArea).offset(-24)
            make.adjustedHeightEqualTo(56)
        }
    }
    
    func setupDataSource() {
        let cellRegistration = CellRegistration<WithdrawalReasonCell, Item> { cell, indexPath, item in
            cell.configure(isSelected: item.isSelected, description: item.reason.rawValue)
            
            cell.checkboxDidTapClosure = { [weak self] in
                self?.viewModel.input.checkbox.send(item.reason)
            }
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        })
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupAction() {
        navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    }
    
    func setupBinding() {
        let output = viewModel.bind(with: cancelBag).share()
        
        output
            .map(\.items)
            .sink { [weak self] items in
                self?.applySnapshot(items: items)
            }
            .store(in: cancelBag)
        
        output
            .map(\.isNextEnabled)
            .handleEvents(receiveOutput: { [weak self] isEnabled in
                isEnabled ? self?.nextButton.updateStyle(.primary) : self?.nextButton.updateStyle(.gray)
            })
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: cancelBag)
        
        output
            .map(\.selectedReasons)
            .sink { selectedReasons in
                
                // TODO: 다음 화면으로 넘어가기
                
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Action

    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper

    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot)
    }
    
    // MARK: - Computed

    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(48.adjustedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(48.adjustedHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Constant
    
    enum Constant {
        static let title = "정말 떠나시는 건가요?"
        static let description = """
                                계정을 삭제하시려는 이유를 말씀해 주세요
                                서비스 개선에 중요한 자료로 활용하겠습니다
                                """
    }
}
