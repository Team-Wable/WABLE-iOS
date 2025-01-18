//
//  MigratedDetailViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/16/25.
//

import UIKit
import Combine

import CombineCocoa

final class MigratedDetailViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Item: Hashable {
        case feed(HomeFeedDTO)
        case reply(FlattenReplyModel)
    }
    
    enum Section: CaseIterable {
        case feed
        case reply
    }
    
    // MARK: - Properties
    
    private var dataSource: DataSource?
    private let viewModel: MigratedDetailViewModel
    
    private let cancelBag = CancelBag()
    private let rootView = MigratedDetailView()
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidRefreshSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidEndDragSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    
    init(viewModel: MigratedDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDataSource()
        setupBinding()
        setupAction()
        setNavigationBar()
        setupDelegate()
        dismissKeyboardTouchOutside(delegate: self)
        
        viewDidLoadSubject.send(())
    }
}

// MARK: - Private Method

private extension MigratedDetailViewController {
    
    func setupDelegate() {
        rootView.bottomWriteView.writeTextView.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func setupCollectionView() {
        rootView.collectionView.setCollectionViewLayout(collectionViewLayout, animated: false)
    }
    
    func setupDataSource() {
        let feedCellRegistration = UICollectionView.CellRegistration<MigratedHomeFeedCell, HomeFeedDTO> {
            cell, index, item in
            cell.seperateLineView.isHidden = false
            cell.bind(data: item)
        }
        
        let replyCellRegistration = UICollectionView.CellRegistration<MigratedDetailCell, FlattenReplyModel> {
            cell, index, item in
            cell.bind(data: item)
            
            cell.bottomView.replyButtonTapped = { [weak self] in
                
                
            }
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            switch item {
            case .feed(let feedData):
                collectionView.dequeueConfiguredReusableCell(
                    using: feedCellRegistration,
                    for: indexPath,
                    item: feedData
                )
                
            case .reply(let replyData):
                collectionView.dequeueConfiguredReusableCell(
                    using: replyCellRegistration,
                    for: indexPath,
                    item: replyData
                )
            }
        }
    }
    
    func applySnapshot(items: [Item], to section: Section) {
        var snapshot = dataSource?.snapshot() ?? Snapshot()
        
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections(Section.allCases)
        }
        
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setupAction() {
        let refreshAction = UIAction { [weak self] _ in
            self?.collectionViewDidRefreshSubject.send(())
        }

        rootView.collectionView.refreshControl?.addAction(refreshAction, for: .valueChanged)
    }
    
    func setupBinding() {
        let input = MigratedDetailViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            collectionViewDidRefresh: collectionViewDidRefreshSubject.eraseToAnyPublisher(),
            collectionViewDidEndDrag: collectionViewDidEndDragSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.feedData
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.endRefreshing()
            })
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [weak self] feed in
                self?.applySnapshot(items: [.feed(feed)], to: .feed)
                self?.makeTextViewEmpty()
            }
            .store(in: cancelBag)
        
        output.replyDatas
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .map { replies in
                replies.map { Item.reply($0) }
            }
            .sink { [weak self] reply in
                self?.applySnapshot(items: reply, to: .reply)
            }
            .store(in: cancelBag)
        
    }
    
    func makeTextViewEmpty() {
        self.rootView.bottomWriteView.writeTextView.text = nil
        self.rootView.bottomWriteView.placeholderLabel.isHidden = false
    }
    
    func endRefreshing() {
        guard let refreshControl = rootView.collectionView.refreshControl,
              refreshControl.isRefreshing else { return }
        refreshControl.endRefreshing()
    }
    
    private func setNavigationBar() {
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.barTintColor = .wableWhite
        self.navigationItem.title = "게시글"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        
        navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
    @objc
    func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
}

extension MigratedDetailViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == rootView.collectionView,
              (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height
        else {
            return
        }
        
        collectionViewDidEndDragSubject.send(())
    }
}

private extension MigratedDetailViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]
            switch sectionKind {
            case .feed:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(170.adjustedH))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(170.adjusted))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                return section
            case .reply:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(150.adjustedH))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(150.adjusted))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                return section
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension MigratedDetailViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 전체 텍스트 삭제를 확인
        let isDeletingAllText = range == NSRange(location: 0, length: textView.text.count) && text.isEmpty
        
        if isDeletingAllText {
            setTextViewHeight(textView, isDeletingAllText: isDeletingAllText)
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setTextViewHeight(textView, isDeletingAllText: false)
        
        let trimmedText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        rootView.bottomWriteView.placeholderLabel.isHidden = !textView.text.isEmpty
        trimmedText.isEmpty ? makeUploadButtonDeactivate() : makeUploadButtonActivate()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            rootView.bottomWriteView.placeholderLabel.isHidden = false
        }
    }
    
    func setTextViewHeight(_ textView: UITextView, isDeletingAllText: Bool) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.isScrollEnabled = !isDeletingAllText && estimatedSize.height >= 95.adjusted
        
        rootView.bottomWriteView.writeTextView.snp.updateConstraints {
            $0.height.lessThanOrEqualTo(100.adjusted)
        }
        
        rootView.bottomWriteView.snp.updateConstraints {
            $0.height.lessThanOrEqualTo(120.adjusted)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func makeUploadButtonActivate() {
        rootView.bottomWriteView.uploadButton.setImage(ImageLiterals.Button.btnRipplePress, for: .normal)
        rootView.bottomWriteView.uploadButton.isEnabled = true
    }
    
    private func makeUploadButtonDeactivate() {
        rootView.bottomWriteView.uploadButton.setImage(ImageLiterals.Button.btnRippleDefault, for: .normal)
        rootView.bottomWriteView.uploadButton.isEnabled = false
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MigratedDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIButton)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
