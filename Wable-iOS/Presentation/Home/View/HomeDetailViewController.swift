//
//  HomeDetailViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//

import Combine
import UIKit

import Lottie

final class HomeDetailViewController: NavigationViewController {
    
    // MARK: - Section
    
    enum Section: Hashable, CaseIterable {
        case content
        case comment
    }
    
    // MARK: - Item
    
    enum Item: Hashable {
        case content(Content)
        case comment(ContentComment)
    }
    
    // MARK: - typealias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property
    
    private var type: CommentType = .ripple
    private var dataSource: DataSource?
    private let viewModel: HomeDetailViewModel
    private let willAppearSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let didContentHeartTappedSubject = PassthroughSubject<Bool, Never>()
    private let didCommentHeartTappedSubject = PassthroughSubject<(Bool, ContentComment), Never>()
    private let didReplyTappedSubject = PassthroughSubject<Int, Never>()
    private let didCommentTappedSubject = PassthroughSubject<Void, Never>()
    private let didGhostTappedSubject = PassthroughSubject<Int, Never>()
    private let didCreateTappedSubject = PassthroughSubject<String, Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let cancelBag: CancelBag
    
    // TODO: ViewModel로 옮겨야 할 로직
    
    private let userInformationUseCase = FetchUserInformationUseCase(
        repository: UserSessionRepositoryImpl(
            userDefaults: UserDefaultsStorage(
                jsonEncoder: JSONEncoder(),
                jsonDecoder: JSONDecoder()
            )
        )
    )
    
    // MARK: - UIComponent
    
    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let underLineView: LottieAnimationView = LottieAnimationView(name: LottieType.tab.rawValue).then {
        $0.contentMode = .scaleToFill
        $0.loopMode = .loop
        $0.play()
    }
    
    private let writeCommentView: UIView = UIView().then {
        $0.backgroundColor = .wableWhite
    }
    
    private lazy var commentTextView: UITextView = UITextView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.isScrollEnabled = false
        $0.backgroundColor = .gray100
        $0.setPretendard(with: .body4)
        $0.textContainer.lineFragmentPadding = .zero
        $0.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private lazy var createCommentButton: UIButton = UIButton().then {
        $0.setImage(.btnRippleDefault, for: .disabled)
        $0.setImage(.btnRipplePress, for: .normal)
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }
    
    // MARK: - LifeCycle
    
    init(viewModel: HomeDetailViewModel, cancelBag: CancelBag) {
        self.viewModel = viewModel
        self.cancelBag = cancelBag
        
        super.init(type: .page(type: .detail, title: "게시글"))
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        willAppearSubject.send()
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
}

// MARK: - Setup Extension

private extension HomeDetailViewController {
    func setupView() {
        view.addSubviews(collectionView, underLineView, writeCommentView, loadingIndicator)
        writeCommentView.addSubviews(commentTextView, createCommentButton)
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(underLineView.snp.top)
        }
        
        underLineView.snp.makeConstraints {
            $0.bottom.equalTo(writeCommentView.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        writeCommentView.snp.makeConstraints {
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
        
        commentTextView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(createCommentButton.snp.leading).offset(-7)
        }
        
        createCommentButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(32.adjustedWidth)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(writeCommentView.snp.top)
        }
    }
    
    func setupDataSource() {
        let contentCellRegistration = UICollectionView.CellRegistration<
            ContentCollectionViewCell,
            Content
        > { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            cell.configureCell(
                info: item.content.contentInfo,
                postType: .mine,
                cellType: .detail,
                likeButtonTapHandler: {
                self.didContentHeartTappedSubject.send(cell.likeButton.isLiked)
            })
            
            cell.commentButton.addAction(UIAction(handler: { _ in
                self.didCommentTappedSubject.send()
                
                self.commentTextView.text = item.content.contentInfo.author.nickname + Constant.ripplePlaceholder
                self.commentTextView.textColor = .gray700
                
                self.commentTextView.endEditing(true)
            }), for: .touchUpInside)
            
            commentTextView.text = item.content.contentInfo.author.nickname + Constant.ripplePlaceholder
            self.commentTextView.textColor = .gray700
        }
        
        let commentCellRegistration = UICollectionView.CellRegistration<
            CommentCollectionViewCell,
            ContentComment
        > { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            self.userInformationUseCase.fetchActiveUserID()
                .sink { id in
                    cell.configureCell(
                        info: item.comment,
                        commentType: item.parentID == -1 ? .ripple : .reply,
                        authorType: item.comment.author.id == id ? .mine : .others,
                        likeButtonTapHandler: {
                            self.didCommentHeartTappedSubject.send((cell.likeButton.isLiked, item))
                        })
                }
                .cancel()
            
            cell.ghostButton.addAction(UIAction(handler: { _ in
                self.didGhostTappedSubject.send(indexPath.item)
            }), for: .touchUpInside)
            
            cell.replyButton.addAction(UIAction(handler: { _ in
                self.didReplyTappedSubject.send(indexPath.item)
                
                self.commentTextView.text = item.comment.author.nickname + Constant.replyPlaceholder
                self.commentTextView.textColor = .gray700
                
                self.commentTextView.endEditing(true)
            }), for: .touchUpInside)
            
            cell.infoView.profileImageView.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(self.profileImageViewDidTap)
                )
            )
        }
        
        dataSource = DataSource(collectionView: collectionView) { (
            collectionView,
            indexPath,
            item
        ) -> UICollectionViewCell? in
            let section = Section.allCases[indexPath.section]
            switch (section, item) {
            case (.content, .content(let content)):
                return collectionView.dequeueConfiguredReusableCell(
                    using: contentCellRegistration,
                    for: indexPath,
                    item: content
                )
            case (.comment, .comment(let comment)):
                return collectionView.dequeueConfiguredReusableCell(
                    using: commentCellRegistration,
                    for: indexPath,
                    item: comment
                )
            default:
                return nil
            }
        }
        
        var snapshot = Snapshot()
        
        snapshot.appendSections([.content, .comment])
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setupAction() {
        createCommentButton.addAction(UIAction(handler: { [weak self] _ in
            guard let text = self?.commentTextView.text else { return }
            
            self?.didCreateTappedSubject.send(text)
        }), for: .touchUpInside)
        collectionView.refreshControl?.addAction(UIAction(handler: { [weak self] _ in
            self?.didRefreshSubject.send()
        }), for: .valueChanged)
    }
    
    func setupDelegate() {
        collectionView.delegate = self
        commentTextView.delegate = self
    }
    
    func setupBinding() {
        let input = HomeDetailViewModel.Input(
            viewWillAppear: willAppearSubject.eraseToAnyPublisher(),
            viewDidRefresh: didRefreshSubject.eraseToAnyPublisher(),
            didContentHeartTappedItem: didContentHeartTappedSubject.eraseToAnyPublisher(),
            didCommentHeartTappedItem: didCommentHeartTappedSubject.eraseToAnyPublisher(),
            didCommentTappedItem: didCommentTappedSubject.eraseToAnyPublisher(),
            didReplyTappedItem: didReplyTappedSubject.eraseToAnyPublisher(),
            didCreateTappedItem: didCreateTappedSubject.eraseToAnyPublisher(),
            willDisplayLastItem: willDisplayLastItemSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.textViewState
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, commentType in
                owner.type = commentType
            }
            .store(in: cancelBag)
        
        output.content
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, contentInfo in
                guard let contentInfo = contentInfo else { return }
                
                owner.userInformationUseCase.fetchActiveUserID()
                    .receive(on: DispatchQueue.main)
                    .sink { id in
                        guard let id = id else { return }
                        
                        let content = Content(
                            content: UserContent(
                                id: id,
                                contentInfo: contentInfo
                            ),
                            isDeleted: false
                        )
                        
                        owner.updateContent(content)
                    }
                    .store(in: owner.cancelBag)
            }
            .store(in: cancelBag)
        
        output.comments
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, comments in
                owner.updateComments(comments)
            }
            .store(in: cancelBag)
        
        output.isLoading
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isLoading in
                if !isLoading {
                    owner.collectionView.refreshControl?.endRefreshing()
                }
            }
            .store(in: cancelBag)
        
        output.isLoadingMore
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isLoadingMore in
                isLoadingMore ? owner.loadingIndicator.startAnimating() : owner.loadingIndicator.stopAnimating()
            }
            .store(in: cancelBag)
        
        output.postSucceed
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isSucceed in
                if isSucceed {
                    owner.commentTextView.text = nil
                    owner.commentTextView.endEditing(true)
                    owner.scrollToTop()
                    
                    let toast = ToastView(status: .complete, message: "댓글을 남겼어요")
                    toast.show()
                }
            }
            .store(in: cancelBag)
    }
}

// MARK: - @objc Method

private extension HomeDetailViewController {
    @objc func profileImageViewDidTap() {
        // TODO: 마이페이지 이동 로직 필요
    }
}

// MARK: - UICollectionViewDelegate

extension HomeDetailViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if Section.allCases[indexPath.section] == .comment {
            let sectionItemCount = dataSource?.snapshot().numberOfItems(inSection: .comment) ?? 0
            
            if indexPath.item >= sectionItemCount - 5 && sectionItemCount > 0 {
                willDisplayLastItemSubject.send()
            }
        }
    }
}

// MARK: - Computed Property

private extension HomeDetailViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (
            sectionIndex,
            layoutEnvironment
        ) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let section = Section.allCases[sectionIndex]
            
            switch section {
            case .content:
                return self.createSection(estimatedHeight: 500)
            case .comment:
                return self.createSection(estimatedHeight: 500)
            }
        }
    }

    private func createSection(estimatedHeight: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedHeight)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedHeight)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}

// MARK: - Helper Method

extension HomeDetailViewController {
    func updateContent(_ content: Content) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .content))
        snapshot.appendItems([.content(content)], toSection: .content)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func updateComments(_ comments: [ContentComment]) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        let commentItems = comments.flatMap { comment -> [Item] in
            var items: [Item] = [.comment(comment)]
            
            if !comment.childs.isEmpty {
                let childItems = comment.childs.map { Item.comment($0) }
                
                items.append(contentsOf: childItems)
            }
            
            return items
        }
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .comment))
        snapshot.appendItems(commentItems, toSection: .comment)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func scrollToTop() {
        collectionView.setContentOffset(.zero, animated: true)
    }
}

// MARK: - UITextViewDelegate
// TODO: 리팩 시 개선 필요

extension HomeDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.contains(Constant.replyPlaceholder) || textView.text.contains(Constant.ripplePlaceholder) {
            textView.text = nil
            textView.textColor = .wableBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let oldText = textView.text,
              let stringRange = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: stringRange, with: text)
        
        return newText.count <= 500
    }
}

// MARK: - Constant

extension HomeDetailViewController {
    enum Constant {
        static let ripplePlaceholder: String = "에게 댓글 남기기..."
        static let replyPlaceholder: String = "에게 답글 남기기..."
    }
}
