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
    
    private let viewModel: HomeDetailViewModel
    private let willAppearSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let didContentHeartTappedSubject = PassthroughSubject<Bool, Never>()
    private let didCommentHeartTappedSubject = PassthroughSubject<(Bool, ContentComment), Never>()
    private let didReplyTappedSubject = PassthroughSubject<(Int, Int), Never>()
    private let didCommentTappedSubject = PassthroughSubject<Void, Never>()
    private let didGhostTappedSubject = PassthroughSubject<(Int, Int, String?, PostType), Never>()
    private let didDeleteTappedSubject = PassthroughSubject<(Int, PostType), Never>()
    private let didBannedTappedSubject = PassthroughSubject<(Int, Int, TriggerType.Ban), Never>()
    private let didReportTappedSubject = PassthroughSubject<(String, String), Never>()
    private let didCreateTappedSubject = PassthroughSubject<String, Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let cancelBag: CancelBag
    
    private var activeUserID: Int?
    private var isActiveUserAdmin: Bool?
    private var type: CommentType = .ripple
    private var dataSource: DataSource?
    
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
        $0.font = .pretendard(.body4)
        $0.textContainer.lineFragmentPadding = .zero
        $0.text = ""
        $0.textContainerInset.top = 12
        $0.textContainerInset.left = 8
        $0.textContainerInset.bottom = 12
    }
    
    private lazy var placeholderLabel: UILabel = UILabel().then {
        $0.textColor = .gray700
        $0.attributedText = " ".pretendardString(with: .body4)
        $0.isUserInteractionEnabled = false
    }
    
    private lazy var createCommentButton: UIButton = UIButton().then {
        $0.setImage(.btnRippleDefault, for: .disabled)
        $0.setImage(.btnRipplePress, for: .normal)
        $0.isEnabled = false
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
        modalPresentationStyle = .fullScreen
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
        setupTapGesture()
        setupDelegate()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        willAppearSubject.send()
    }
}

// MARK: - Setup Method

private extension HomeDetailViewController {
    func setupView() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.addSubviews(collectionView, underLineView, writeCommentView, loadingIndicator)
        writeCommentView.addSubviews(commentTextView, createCommentButton, placeholderLabel)
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
            $0.height.greaterThanOrEqualTo(42.adjustedHeight)
            $0.height.lessThanOrEqualTo(76.adjustedHeight)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(commentTextView).inset(10)
            $0.top.equalTo(commentTextView).offset(10)
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
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupDataSource() {
        let contentCellRegistration = UICollectionView.CellRegistration <
            ContentCollectionViewCell,
            Content
        > {
            [weak self] cell,
            indexPath,
            item in
            guard let self = self else { return }
            
            cell.divideView.snp.updateConstraints { make in
                make.height.equalTo(8)
            }
            
            cell.configureCell(
                info: item.content.contentInfo,
                authorType: item.content.contentInfo.author.id == self.activeUserID ? .mine : .others,
                cellType: .detail,
                contentImageViewTapHandler: {
                    guard let image = cell.contentImageView.image else { return }
                    
                    let photoDetailViewController = PhotoDetailViewController(image: image)
                    self.navigationController?.pushViewController(photoDetailViewController, animated: true)
                },
                likeButtonTapHandler: {
                    AmplitudeManager.shared.trackEvent(tag: .clickLikeComment)
                    
                    self.didContentHeartTappedSubject.send(cell.likeButton.isLiked)
                },
                settingButtonTapHandler: {
                    let viewController = WableBottomSheetController()
                    
                    if self.activeUserID == item.content.contentInfo.author.id {
                        viewController.addActions(WableBottomSheetAction(title: "삭제하기", handler: {
                            viewController.dismiss(animated: true, completion: {
                                let viewController = WableSheetViewController(title: StringLiterals.Delete.contentSheetTitle, message: StringLiterals.Delete.contentSheetMessage)
                                
                                viewController.addActions(
                                    WableSheetAction(title: "취소", style: .gray),
                                    WableSheetAction(
                                        title: "삭제하기",
                                        style: .primary,
                                        handler: {
                                            viewController.dismiss(animated: true, completion: {
                                                self.didDeleteTappedSubject.send((item.content.id, .content))
                                            })
                                        }
                                    )
                                )
                                
                                self.present(viewController, animated: true)
                            })
                        }))
                    } else if self.isActiveUserAdmin ?? false {
                        let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                            self?.showReportSheet(
                                onPrimary: { message in
                                    viewController.dismiss(
                                        animated: true,
                                        completion: {
                                            self?.didReportTappedSubject.send(
                                                (
                                                    item.content.contentInfo.author.nickname,
                                                    message ?? item.content.contentInfo.text
                                                )
                                            )
                                        })
                                })
                        }
                        let banAction = WableBottomSheetAction(title: "밴하기") { [weak self] in
                            self?.didBannedTappedSubject.send((item.content.contentInfo.author.id, item.content.id, .content))
                        }
                        self.showBottomSheet(actions: reportAction, banAction)
                    } else {
                        let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                            self?.showReportSheet(
                                onPrimary: { message in
                                    viewController.dismiss(
                                        animated: true,
                                        completion: {
                                            viewController.dismiss(
                                                animated: true,
                                                completion: {
                                                    self?.didReportTappedSubject.send(
                                                        (
                                                            item.content.contentInfo.author.nickname,
                                                            message ?? item.content.contentInfo.text
                                                        )
                                                    )
                                            })
                                        })
                                })
                        }
                        self.showBottomSheet(actions: reportAction)
                    }
                    
                    self.present(viewController, animated: true)
                },
                profileImageViewTapHandler: {
                    if self.activeUserID == item.content.contentInfo.author.id,
                       let tabBarController = self.tabBarController {
                        tabBarController.selectedIndex = 4
                    } else {
                        let viewController = OtherProfileViewController(
                            viewModel: .init(
                                userID: item.content.contentInfo.author.id,
                                fetchUserProfileUseCase: FetchUserProfileUseCaseImpl(),
                                checkUserRoleUseCase: CheckUserRoleUseCaseImpl(
                                    repository: UserSessionRepositoryImpl(
                                        userDefaults: .init(
                                            jsonEncoder: .init(),
                                            jsonDecoder: .init()
                                        )
                                    )
                                )
                            ))
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                },
                ghostButtonTapHandler: {
                    AmplitudeManager.shared.trackEvent(tag: .clickGhostPost)
                    self.showGhostSheet(onCancel: {
                        AmplitudeManager.shared.trackEvent(tag: .clickWithdrawghostPopup)
                    }, onPrimary: { message in
                        AmplitudeManager.shared.trackEvent(tag: .clickApplyghostPopup)
                        
                        self.didGhostTappedSubject.send((item.content.id, item.content.contentInfo.author.id, message, .content))
                    })
                }
            )
            
            cell.commentButton.addAction(UIAction(handler: { _ in
                AmplitudeManager.shared.trackEvent(tag: .clickWriteComment)
                
                self.createCommentButton.isEnabled = false
                self.didCommentTappedSubject.send()
                
                self.commentTextView.text = ""
                self.updatePlaceholder(for: item.content.contentInfo.author.nickname, type: .ripple)
                
                self.commentTextView.endEditing(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.commentTextView.becomeFirstResponder()
                }
            }), for: .touchUpInside)
            
            if let text = placeholderLabel.text,
               !text.contains(Constant.replyPlaceholder) && !text.contains(Constant.ripplePlaceholder) {
                self.updatePlaceholder(for: item.content.contentInfo.author.nickname, type: .ripple)
            }
        }
        
        let commentCellRegistration = UICollectionView.CellRegistration <
            CommentCollectionViewCell,
            ContentComment
        > {
            [weak self] cell,
            indexPath,
            item in
            guard let self = self else { return }
            
            cell.configureCell(
                info: item.comment,
                commentType: item.parentID == -1 ? .ripple : .reply,
                authorType: item.comment.author.id == activeUserID ? .mine : .others,
                likeButtonTapHandler: {
                    self.didCommentHeartTappedSubject.send((cell.likeButton.isLiked, item))
                },
                settingButtonTapHandler: {
                    let viewController = WableBottomSheetController()
                    
                    if self.activeUserID == item.comment.author.id {
                        viewController.addActions(WableBottomSheetAction(title: "삭제하기", handler: {
                            viewController.dismiss(animated: true, completion: {
                                let viewController = WableSheetViewController(title: StringLiterals.Delete.commentSheetTitle, message: StringLiterals.Delete.commentSheetMessage)
                                
                                viewController.addActions(
                                    WableSheetAction(
                                        title: "취소",
                                        style: .gray,
                                        handler: {
                                            viewController.dismiss(animated: true)
                                        }
                                    ),
                                    WableSheetAction(
                                        title: "삭제하기",
                                        style: .primary,
                                        handler: {
                                            viewController.dismiss(animated: true, completion: {
                                                self.didDeleteTappedSubject.send((item.comment.id, .comment))
                                            })
                                        }
                                    )
                                )
                                
                                self.present(viewController, animated: true)
                            })
                        }))
                    } else if self.isActiveUserAdmin ?? false {
                        let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                            self?.showReportSheet(
                                onPrimary: { message in
                                    viewController.dismiss(
                                        animated: true,
                                        completion: {
                                            self?.didReportTappedSubject.send((item.comment.author.nickname, message ?? item.comment.text))
                                        })
                                })
                        }
                        let banAction = WableBottomSheetAction(title: "밴하기") { [weak self] in
                            self?.didBannedTappedSubject.send((item.comment.author.id, item.comment.id, .comment))
                        }
                        self.showBottomSheet(actions: reportAction, banAction)
                    } else {
                        let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                            self?.showReportSheet(
                                onPrimary: { message in
                                    viewController.dismiss(
                                        animated: true,
                                        completion: {
                                            self?.didReportTappedSubject.send(
                                                (
                                                    item.comment.author.nickname,
                                                    message ?? item.comment.text
                                                )
                                            )
                                        })
                                })
                        }
                        self.showBottomSheet(actions: reportAction)
                    }
                    
                    self.present(viewController, animated: true)
                },
                profileImageViewTapHandler: {
                    if self.activeUserID == item.comment.author.id,
                       let tabBarController = self.tabBarController {
                        tabBarController.selectedIndex = 4
                    } else {
                        let viewController = OtherProfileViewController(
                            viewModel: .init(
                                userID: item.comment.author.id,
                                fetchUserProfileUseCase: FetchUserProfileUseCaseImpl(),
                                checkUserRoleUseCase: CheckUserRoleUseCaseImpl(
                                    repository: UserSessionRepositoryImpl(
                                        userDefaults: .init(
                                            jsonEncoder: .init(),
                                            jsonDecoder: .init()
                                        )
                                    )
                                )
                            ))
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                },
                ghostButtonTapHandler: {
                    AmplitudeManager.shared.trackEvent(tag: .clickGhostComment)
                    self.showGhostSheet(onCancel: {
                        AmplitudeManager.shared.trackEvent(tag: .clickWithdrawghostPopup)
                    }, onPrimary: { message in
                        AmplitudeManager.shared.trackEvent(tag: .clickApplyghostPopup)
                        
                        self.didGhostTappedSubject.send((item.comment.id, item.comment.author.id, message, .comment))
                    })
                },
                replyButtonTapHandler: {
                    AmplitudeManager.shared.trackEvent(tag: .clickWriteRecomment)
                    
                    self.createCommentButton.isEnabled = false
                    self.didReplyTappedSubject.send((item.comment.id, item.comment.author.id))
                    
                    self.commentTextView.text = ""
                    self.updatePlaceholder(for: item.comment.author.nickname, type: .reply)
                    
                    self.commentTextView.endEditing(true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.commentTextView.becomeFirstResponder()
                    }
                }
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
            guard let self = self,
                  !self.commentTextView.text.isEmpty
            else {
                return
            }
            
            AmplitudeManager.shared.trackEvent(tag: .clickUploadComment)
            createCommentButton.isUserInteractionEnabled = false
            self.didCreateTappedSubject.send(self.commentTextView.text)
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
            didGhostTappedItem: didGhostTappedSubject.eraseToAnyPublisher(),
            didDeleteTappedItem: didDeleteTappedSubject.eraseToAnyPublisher(),
            didBannedTappedItem: didBannedTappedSubject.eraseToAnyPublisher(),
            didReportTappedItem: didReportTappedSubject.eraseToAnyPublisher(),
            willDisplayLastItem: willDisplayLastItemSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.isAdmin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAdmin in
                self?.isActiveUserAdmin = isAdmin
            }
            .store(in: cancelBag)
        
        output.activeUserID
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                self?.activeUserID = id
            }
            .store(in: cancelBag)
        
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
                guard let contentInfo = contentInfo,
                      let activeUserID = owner.activeUserID
                else {
                    return
                }
                
                owner.updateContent(Content(content: UserContent(id: activeUserID, contentInfo: contentInfo), isDeleted: false))
            }
            .store(in: cancelBag)
        
        output.contentNotFound
            .sink { [weak self] _ in
                self?.showNotFoundViewController()
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
                    let toast = ToastView(status: .complete, message: StringLiterals.Detail.rippleCompleteToast)
                    
                    toast.show()
                    owner.scrollToTop()
                    owner.commentTextView.text = ""
                    owner.commentTextView.isScrollEnabled = false
                    owner.commentTextView.sizeToFit()
                    owner.commentTextView.setNeedsUpdateConstraints()
                    owner.commentTextView.superview?.layoutIfNeeded()
                    owner.commentTextView.endEditing(true)
                    owner.placeholderLabel.isHidden = false
                    owner.createCommentButton.isUserInteractionEnabled = true
                }
            }
            .store(in: cancelBag)
        
        output.isReportSucceed
            .receive(on: DispatchQueue.main)
            .sink { isSucceed in
                let toast = ToastView(
                    status: .complete,
                    message: StringLiterals.Report.completeToast
                )
                
                isSucceed ? toast.show() : nil
            }
            .store(in: cancelBag)
        
        output.isContentDeleted
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isSucceed in
                if isSucceed {
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: cancelBag)
    }
    
    func updatePlaceholder(for authorNickname: String, type: CommentType) {
        let placeholderText = authorNickname + (type == .ripple ? Constant.ripplePlaceholder : Constant.replyPlaceholder)
        placeholderLabel.text = placeholderText
        placeholderLabel.isHidden = !commentTextView.text.isEmpty
    }
}

// MARK: - @objc method

extension HomeDetailViewController {
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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

// MARK: - UIGestureRecognizerDelegate

extension HomeDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view == createCommentButton)
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
            guard !comment.isDeleted else { return [] }
            
            var items: [Item] = [.comment(comment)]
            
            if !comment.childs.isEmpty {
                let childItems = comment.childs
                    .filter { !$0.isDeleted }
                    .map { Item.comment($0) }
                
                items.append(contentsOf: childItems)
            }
            
            return items
        }
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .comment))
        snapshot.appendItems(commentItems, toSection: .comment)
        
        dataSource?.apply(snapshot, animatingDifferences: false)
        
        collectionView.layoutIfNeeded()
    }

    func scrollToTop() {
        collectionView.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(.zero, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.collectionView.layoutIfNeeded()
            }
        }
    }
    
    func showNotFoundViewController() {
        let tabBar = navigationController?.tabBarController
        let notFoundViewController = NotFoundViewController { [weak self] in
            self?.navigationController?.popToRootViewController(animated: false)
            tabBar?.selectedIndex = 0
        }
        present(notFoundViewController, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension HomeDetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let oldText = textView.text,
              let stringRange = Range(range, in: oldText)
        else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: stringRange, with: text)
        
        return newText.count <= 500
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility(textView)
        
        createCommentButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        let isMaxHeight = estimatedSize.height >= 80.adjustedHeight
        guard isMaxHeight != textView.isScrollEnabled else { return }
        
        textView.isScrollEnabled = isMaxHeight
        textView.reloadInputViews()
        textView.setNeedsUpdateConstraints()
        
        textView.superview?.layoutIfNeeded()
    }
    
    private func updatePlaceholderVisibility(_ textView: UITextView) {
        let hasText = !textView.text.isEmpty
        let hasMarkedText = textView.markedTextRange != nil
        
        placeholderLabel.isHidden = hasText || hasMarkedText
    }
}

    // MARK: - Constant

extension HomeDetailViewController {
    enum Constant {
        static let ripplePlaceholder: String = "에게 댓글 남기기..."
        static let replyPlaceholder: String = "에게 답글 남기기..."
    }
}
