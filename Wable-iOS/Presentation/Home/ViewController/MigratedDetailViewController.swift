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
    
    var feedDeleted: (() -> Void)?
    var backToFeed: ((HomeFeedDTO) -> Void)?
    
    private var dataSource: DataSource?
    private var photoDetailView: WablePhotoDetailView?

    private let viewModel: MigratedDetailViewModel
    private let cancelBag = CancelBag()
    private let rootView = MigratedDetailView()
    private let bottomSheetView = HomeBottomSheetView()
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidRefreshSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidEndDragSubject = PassthroughSubject<Void, Never>()
    private let replyButtonTapSubject = PassthroughSubject<FlattenReplyModel?, Never>()
    private let menuButtonTapSubject = PassthroughSubject<FlattenReplyModel?, Never>()
    private let profileImageTapSubject = PassthroughSubject<FlattenReplyModel?, Never>()
    private let heartButtonTapSubject = PassthroughSubject<FlattenReplyModel?, Never>()
    private let feedImageTapSubject = PassthroughSubject<Void, Never>()
    private let postReplyButtonTapSubject = PassthroughSubject<String, Never>()
    
    private let replyDeleteButtonDidTappedSubject = PassthroughSubject<Int, Never>()
    private let ghostButtonDidTappedSubject = PassthroughSubject<Int?, Never>()
    
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
        popupEventBinding()
        setupAction()
        setNavigationBar()
        setupDelegate()
        dismissKeyboardTouchOutside(delegate: self)
        
        viewDidLoadSubject.send(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backToFeed?(viewModel.feedSubject.value ?? viewModel.defalutHomeFeedDTO())
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
            cell.onCommentButtonTap = { [weak self] in
                guard let self else { return }
                rootView.bottomWriteView.writeTextView.resignFirstResponder()
                rootView.bottomWriteView.writeTextView.becomeFirstResponder()
                replyButtonTapSubject.send(nil)
                makeTextViewEmpty()
            }
            
            cell.onMenuButtonTap = { [weak self] in
                self?.menuButtonTapSubject.send(nil)
            }
            
            cell.onProfileImageTap = { [weak self] in
                self?.profileImageTapSubject.send(nil)
            }
            
            cell.onHeartButtonTap = { [weak self] in
                self?.heartButtonTapSubject.send(nil)
            }
            
            cell.onGhostButtonTap = { [weak self] in
                let target = PopupModel(
                    memberID: item.memberID,
                    contentType: .content,
                    triggerID: item.contentID ?? -1,
                    nickname: item.memberNickname,
                    relatedText: item.contentTitle ?? ""
                )
                self?.presentPopup(popupType: .ghost, data: target)
            }
            
            cell.onFeedImageTap = { [weak self] in
                self?.feedImageTapSubject.send()
            }
        }
        
        let replyCellRegistration = UICollectionView.CellRegistration<MigratedDetailCell, FlattenReplyModel> {
            cell, index, item in
            cell.bind(data: item)
            cell.bottomView.replyButtonTapped = { [weak self] in
                guard let self else { return }
                rootView.bottomWriteView.writeTextView.resignFirstResponder()
                rootView.bottomWriteView.writeTextView.becomeFirstResponder()
                replyButtonTapSubject.send(item)
                makeTextViewEmpty()
            }
            
            cell.menuButtonTapped = { [weak self] in
                self?.menuButtonTapSubject.send(item)
            }
            
            cell.profileButtonAction = { [weak self] in
                self?.profileImageTapSubject.send(item)
            }
            
            cell.bottomView.heartButtonTapped = { [weak self] in
                self?.heartButtonTapSubject.send(item)
            }
            
            cell.bottomView.ghostButtonTapped = { [weak self] in
                let target = PopupModel(
                    memberID: item.memberID,
                    contentType: .content,
                    triggerID: item.commentID,
                    nickname: item.memberNickname,
                    relatedText: item.commentText
                )
                                
                self?.presentPopup(popupType: .ghost, data: target)
                
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

    func applySnapshot(items: [Item], to section: Section, animating: Bool) {
        var snapshot = dataSource?.snapshot() ?? Snapshot()
        
        if snapshot.sectionIdentifiers.contains(section) {
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
        } else {
            snapshot.appendSections([section])
        }
        
        snapshot.appendItems(items, toSection: section)
        
        dataSource?.apply(snapshot, animatingDifferences: animating)
    }
    
    func setupAction() {
        let refreshAction = UIAction { [weak self] _ in
            self?.collectionViewDidRefreshSubject.send(())
        }

        rootView.collectionView.refreshControl?.addAction(refreshAction, for: .valueChanged)
        
        rootView.bottomWriteView.uploadButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                rootView.bottomWriteView.writeTextView.resignFirstResponder()
                postReplyButtonTapSubject.send(rootView.bottomWriteView.writeTextView.text)
            }
            .store(in: cancelBag)
    }
    
    func setupBinding() {
        let input = MigratedDetailViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            collectionViewDidRefresh: collectionViewDidRefreshSubject.eraseToAnyPublisher(),
            collectionViewDidEndDrag: collectionViewDidEndDragSubject.eraseToAnyPublisher(),
            replyButtonDidTapped: replyButtonTapSubject.eraseToAnyPublisher(),
            menuButtonDidTapped: menuButtonTapSubject.eraseToAnyPublisher(),
            profileImageDidTapped: profileImageTapSubject.eraseToAnyPublisher(),
            heartButtonDidTapped: heartButtonTapSubject.eraseToAnyPublisher(),
            feedImageURL: feedImageTapSubject.eraseToAnyPublisher(),
            postReplyButtonDidTapped: postReplyButtonTapSubject.eraseToAnyPublisher()
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
                guard let self else { return }
                applySnapshot(
                    items: [.feed(feed)],
                    to: .feed,
                    animating: false
                )
                makeTextViewEmpty()
            }
            .store(in: cancelBag)
        
        output.replyDatas
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .map { replies in
                replies.map { Item.reply($0) }
            }
            .sink { [weak self] reply in
                self?.applySnapshot(
                    items: reply,
                    to: .reply,
                    animating: false
                )
            }
            .store(in: cancelBag)
        
        output.changedPlaceholder
            .receive(on: RunLoop.main)
            .sink { [weak self] placeholder in
                self?.setPlaceholder(text: placeholder)
            }
            .store(in: cancelBag)
        
        output.showBottomSheet
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                let isMine = loadUserData()?.memberId == data.memberID
                let isAdmin = loadUserData()?.isAdmin
                self?.setBottomSheetButton(
                    isMine: isMine,
                    isAdmin: isAdmin ?? false,
                    data: data
                )
            }
            .store(in: cancelBag)
        
        output.profileImageTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] memberID in
                if memberID == loadUserData()?.memberId {
                    self?.tabBarController?.selectedIndex = 3
                } else {
                    let viewController = MyPageViewController(
                        viewModel: MyPageViewModel(networkProvider: NetworkService()),
                        likeViewModel: LikeViewModel(networkProvider: NetworkService())
                    )
                    viewController.memberId = memberID
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .store(in: cancelBag)
        
        output.toggleFeedHeartButton
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                var snapshot = Snapshot()
                snapshot.appendSections([.feed, .reply])
                snapshot.appendItems([.feed(data)], toSection: .feed)
                let replies = viewModel.replySubject.value
                snapshot.appendItems(replies.map { Item.reply($0) }, toSection: .reply)
                dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: cancelBag)
        
        output.toggleReplyHeartButton
            .receive(on: RunLoop.main)
            .sink { [weak self] datas in
                guard let self = self else { return }
                var snapshot = Snapshot()
                let feedData = viewModel.feedSubject.value ?? viewModel.defalutHomeFeedDTO()
                snapshot.appendSections([.feed, .reply])
                snapshot.appendItems([.feed(feedData)], toSection: .feed)
                snapshot.appendItems(datas.map { Item.reply($0) }, toSection: .reply)
                dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: cancelBag)
        
        output.feedImageTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] imageURL in
                self?.makePhotoDetailView(imageURL: imageURL)
            }
            .store(in: cancelBag)
        
        output.postReplyComplete
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.makeTextViewEmpty()
                self.rootView.bottomWriteView.uploadButton.setImage(
                    ImageLiterals.Button.btnRippleDefault,
                    for: .normal
                )
                self.collectionViewDidRefreshSubject.send()
                makeToast(toastImage: ImageLiterals.Toast.toastSuccess)
            }
            .store(in: cancelBag)
    }
    
    func popupEventBinding() {
        ghostButtonDidTappedSubject.sink { [weak self] triggerID in
            guard let self else { return }
            guard let triggerID = triggerID else { return }
            let updatedFeed = viewModel.updateFeedGhostState(for: triggerID)
            let updatedReplies = viewModel.updateReplyGhostState(for: triggerID)
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            
            snapshot.appendSections([.feed, .reply])
            snapshot.appendItems([.feed(updatedFeed)], toSection: .feed)
            snapshot.appendItems(updatedReplies.map { Item.reply($0) }, toSection: .reply)
            
            dataSource?.apply(snapshot, animatingDifferences: true)
            makeToast(toastImage: ImageLiterals.Toast.toastGhost)
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
    
    func setPlaceholder(text: String) {
        rootView.bottomWriteView.placeholderLabel.isHidden = false
        rootView.bottomWriteView.placeholderLabel.text = text
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
    
    func setBottomSheetButton(isMine: Bool, isAdmin: Bool, data: PopupModel) {
        let bottomSheetHeight = isAdmin ? 178.adjusted : 122.adjusted
        bottomSheetView.bottomsheetView.snp.remakeConstraints {
            $0.height.equalTo(bottomSheetHeight)
        }
        bottomSheetView.showSettings()
        bottomSheetView.deleteButton.isHidden = !isMine
        bottomSheetView.reportButton.isHidden = isMine
        bottomSheetView.banButton.isHidden = !isAdmin
        
        setBottomSheetButtonAction(isMine: isMine, data: data)
    }
    
    func setBottomSheetButtonAction(isMine: Bool, data: PopupModel) {

        let bottomSheetCancelBag = CancelBag()
        bottomSheetView.cancelBag = bottomSheetCancelBag
        
        if isMine {
            bottomSheetView.deleteButton.tapPublisher
                .sink { [weak self] in
                    self?.presentPopup(popupType: .delete, data: data)
                }
                .store(in: bottomSheetCancelBag)
        } else {
            bottomSheetView.reportButton.tapPublisher
                .sink { [weak self] in
                    self?.presentPopup(popupType: .report, data: data)
                }
                .store(in: bottomSheetCancelBag)
        }
        
        if loadUserData()?.isAdmin ?? false {
            bottomSheetView.banButton.tapPublisher
                .sink { [weak self] in
                    self?.presentPopup(popupType: .ban, data: data)
                }
                .store(in: bottomSheetCancelBag)
        }
    }
    
    func presentPopup(popupType: PopupViewType, data: PopupModel) {
        removeBottomsheetView()
        let popupViewController = HomePopupViewController(
            viewModel: PopupViewModel(data: data),
            popupType: popupType
        )
                
        popupViewController.deleteButtonDidTapAction = { [weak self] triggerID, triggerType in
            guard let self else { return }
            collectionViewDidRefreshSubject.send()
        }
        
        popupViewController.reportButtonDidTapAction = { [weak self] in
            self?.makeToast(toastImage: ImageLiterals.Toast.toastReport)
        }
        
        popupViewController.ghostButtonDidTapAction = { [weak self] memberID, _ in
            guard let self else { return }
            
            makeToast(toastImage: ImageLiterals.Toast.toastGhost)
            ghostButtonDidTappedSubject.send(memberID)
            
        }
        
        popupViewController.banButtonDidTapAction = { [weak self] memberID, triggerType in
            guard let self else { return }
            collectionViewDidRefreshSubject.send()
            makeToast(toastImage: ImageLiterals.Toast.toastBan)
        }
        
        popupViewController.modalPresentationStyle = .overFullScreen
        popupViewController.modalTransitionStyle = .crossDissolve
        present(popupViewController, animated: true)
    }
    
    func removeBottomsheetView() {
        if UIApplication.shared.keyWindowInConnectedScenes != nil {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: {
                    self.bottomSheetView.dimView.alpha = 0
                    if let window = UIApplication.shared.keyWindowInConnectedScenes {
                        self.bottomSheetView.bottomsheetView.frame = CGRect(
                            x: 0,
                            y: window.frame.height,
                            width: self.bottomSheetView.frame.width,
                            height: self.bottomSheetView.bottomsheetView.frame.height
                        )
                    }
                }
            )
            bottomSheetView.dimView.removeFromSuperview()
            bottomSheetView.bottomsheetView.removeFromSuperview()
        }
    }
    
    func makePhotoDetailView(imageURL: String) {
        
        self.photoDetailView = WablePhotoDetailView()
        
        guard let photoDetailView = self.photoDetailView,
              let window = UIApplication.shared.keyWindowInConnectedScenes else { return }
        
        window.addSubview(photoDetailView)
        
        photoDetailView.removePhotoButton.tapPublisher
            .sink { [weak self] in
                self?.photoDetailView?.removeFromSuperview()
                self?.photoDetailView = nil
            }
            .store(in: self.cancelBag)
        
        photoDetailView.photoImageView.loadContentImage(url: imageURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.photoDetailView?.updateImageViewHeight(with: image)
            }
        }
        
        photoDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func makeToast(toastImage: UIImage) {
        let toastImageView = UIImageView(image: toastImage)
        toastImageView.contentMode = .scaleAspectFit
        
        if let window = UIApplication.shared.keyWindowInConnectedScenes {
            window.addSubviews(toastImageView)
        }
        
        toastImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(75.adjusted)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343.adjusted)
        }
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn) {
            toastImageView.alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            toastImageView.removeFromSuperview()
        }
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
