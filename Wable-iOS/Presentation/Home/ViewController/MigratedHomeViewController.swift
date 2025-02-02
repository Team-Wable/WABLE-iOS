//
//  MigratedHomeViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 12/22/24.
//

import UIKit
import Combine

import CombineCocoa

final class MigratedHomeViewController: UIViewController {
    
    typealias Item = HomeFeedDTO
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: CaseIterable {
        case feed
    }
    
    // MARK: - Properties
    
    private var dataSource: DataSource?
    
    private let viewModel: MigratedHomeViewModel
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidRefreshSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidSelectedSubject = PassthroughSubject<Int, Never>()
    private let collectionViewDidEndDragSubject = PassthroughSubject<Void, Never>()
    private let profileImageTapSubject = PassthroughSubject<Int, Never>()
    private let menuButtonTapSubject = PassthroughSubject<Int, Never>()
    private let feedImageTapSubject = PassthroughSubject<Int, Never>()
    private let heartButtonTapSubject = PassthroughSubject<Int, Never>()
    private let commentButtonTapSubject = PassthroughSubject<Int, Never>()
    
    private let feedDeleteButtonDidTap = PassthroughSubject<Int, Never>()
    private let feedGhostButtonDidTap = PassthroughSubject<Int, Never>()
    private let feedBanButtonDidTap = PassthroughSubject<Int, Never>()
    
    private let cancelBag = CancelBag()
    private let rootView = MigratedHomeView()
    private var photoDetailView: WablePhotoDetailView?
    private let homeBottomsheetView = HomeBottomSheetView()
    private let reportToastImageView = UIImageView(image: ImageLiterals.Toast.toastReport)
    
    // MARK: - Initializer
    
    init(viewModel: MigratedHomeViewModel) {
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
        setupAction()
        setupBinding()
        popupEventBinding()
        showLoadView()
        
        viewDidLoadSubject.send(())

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - UICollectionViewDelegate

extension MigratedHomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewDidSelectedSubject.send(indexPath.item)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == rootView.collectionView,
              (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height
        else {
            return
        }
        
        collectionViewDidEndDragSubject.send(())
    }
}

// MARK: - Private Method

private extension MigratedHomeViewController {
    func setupCollectionView() {
        rootView.collectionView.setCollectionViewLayout(collectionViewLayout, animated: false)
        
        rootView.collectionView.delegate = self
    }
    
    func setupDataSource() {
        let homeFeedCellRegistration = UICollectionView.CellRegistration<MigratedHomeFeedCell, Item> { cell, indexPath, item in
            cell.bind(data: item)
            cell.onMenuButtonTap = { [weak self] in
                self?.menuButtonTapSubject.send(indexPath.item)
            }
            
            cell.onProfileImageTap = { [weak self] in
                self?.profileImageTapSubject.send(indexPath.item)
            }
            
            cell.onFeedImageTap = { [weak self] in
                self?.feedImageTapSubject.send(indexPath.item)
            }
            
            cell.onHeartButtonTap = { [weak self] in
                self?.heartButtonTapSubject.send(indexPath.item)
            }
            
            cell.onCommentButtonTap = { [weak self] in
                self?.commentButtonTapSubject.send(indexPath.item)
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
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: homeFeedCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func applySnapshot(items: [Item], to section: Section) {
        var snapshot = Snapshot()
        snapshot.appendSections([.feed])
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setupAction() {
        let refreshAction = UIAction { [weak self] _ in
            self?.collectionViewDidRefreshSubject.send(())
        }

        rootView.collectionView.refreshControl?.addAction(refreshAction, for: .valueChanged)
        
        rootView.writeFeedButton.tapPublisher
            .sink { [weak self] _ in
                let writeViewController = WriteViewController(viewModel: WriteViewModel(networkProvider: NetworkService()))
                writeViewController.hidesBottomBarWhenPushed = true
                writeViewController.writeViewDidDisappear = { [weak self] in
                    self?.viewDidLoadSubject.send(())
                }
                self?.navigationController?.pushViewController(writeViewController, animated: true)
            }
            .store(in: cancelBag)
    }
    
    func setupBinding() {
        let input = MigratedHomeViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            collectionViewDidRefresh: collectionViewDidRefreshSubject.eraseToAnyPublisher(),
            collectionViewDidSelect: collectionViewDidSelectedSubject.eraseToAnyPublisher(),
            collectionViewDidEndDrag: collectionViewDidEndDragSubject.eraseToAnyPublisher(),
            menuButtonDidTap: menuButtonTapSubject.eraseToAnyPublisher(),
            profileImageDidTap: profileImageTapSubject.eraseToAnyPublisher(),
            feedImageURL: feedImageTapSubject.eraseToAnyPublisher(),
            heartButtonDidTap: heartButtonTapSubject.eraseToAnyPublisher(),
            commentButtonDidTap: commentButtonTapSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.feedData
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.endRefreshing()
            })
            .removeDuplicates()
            .sink { [weak self] feed in
                self?.applySnapshot(items: feed, to: .feed)
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
        
        output.feedImageTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] imageURL in
                self?.makePhotoDetailView(imageURL: imageURL)
            }
            .store(in: cancelBag)
        
        output.selectedFeed
            .receive(on: RunLoop.main)
            .sink { [weak self] feed in
                self?.pushToDetailView(feed: feed)
            }
            .store(in: cancelBag)
        
        output.toggleHeartButton
            .receive(on: RunLoop.main)
            .sink { [weak self] datas, index in
                guard let self = self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.feed])
                snapshot.appendItems(datas, toSection: .feed)
                dataSource?.apply(snapshot, animatingDifferences: false)
            }
            .store(in: cancelBag)
        
        output.showBottomSheet
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                let isMine = loadUserData()?.memberId == data.memberID
                let isAdmin = loadUserData()?.isAdmin
                self?.setBottomSheetButton(isMine: isMine, isAdmin: isAdmin ?? false, data: data)
            }
            .store(in: cancelBag)
    }
    
    func popupEventBinding() {
        feedDeleteButtonDidTap.sink { [weak self] contentID in
            guard let self else { return }
            viewModel.deleteFeed(at: contentID)
            var snapshot = dataSource?.snapshot()
            if let itemToDelete = snapshot?.itemIdentifiers.first(where: { $0.contentID == contentID }) {
                snapshot?.deleteItems([itemToDelete])
                dataSource?.apply(snapshot ?? NSDiffableDataSourceSnapshot<Section, Item>(), animatingDifferences: true)
            }
        }
        .store(in: cancelBag)
        
        feedGhostButtonDidTap.sink { [weak self] memberID in
            guard let self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            snapshot.appendSections([.feed])
            snapshot.appendItems(viewModel.updateGhostState(for: memberID), toSection: .feed)
            dataSource?.apply(snapshot, animatingDifferences: true)
            
            makeToast(toastImage: ImageLiterals.Toast.toastGhost)
        }
        .store(in: cancelBag)
    }
    
    func endRefreshing() {
        guard let refreshControl = rootView.collectionView.refreshControl,
              refreshControl.isRefreshing else { return }
        refreshControl.endRefreshing()
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

private extension MigratedHomeViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
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
            
            let sectionKind = Section.allCases[sectionIndex]
            switch sectionKind {
            case .feed:
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            }
            return section
        }
    }
}

extension MigratedHomeViewController {
    func scrollToTop() {
        self.rootView.collectionView.setContentOffset(CGPoint(x: 0, y: -self.rootView.collectionView.contentInset.top), animated: true)
    }
    
    func showLoadView() {
        displayLoadingView()
    }
    
    func pushToDetailView(feed: HomeFeedDTO) {
        let detailViewController = MigratedDetailViewController(viewModel: MigratedDetailViewModel(contentID: feed.contentID ?? -1))
        detailViewController.hidesBottomBarWhenPushed = true
        detailViewController.feedDeleted = { [weak self] in
            self?.viewDidLoadSubject.send(())
        }
        
        detailViewController.backToFeed = { [weak self] feed in
            guard let self else { return }
            let feedDatas = viewModel.updatedFeed(of: feed)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            snapshot.appendSections([.feed])
            snapshot.appendItems(feedDatas, toSection: .feed)
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func displayLoadingView() {
        tabBarController?.tabBar.isHidden = true
        self.rootView.loadingView.alpha = 1.0
        self.rootView.loadingView.isHidden = false
        self.rootView.loadingView.loadingLabel.setTextWithLineHeight(
            text: self.rootView.loadingView.loadingText.randomElement(),
            lineHeight: 32.adjusted,
            alignment: .center
        )
        self.rootView.loadingView.lottieLoadingView.play(
            fromProgress: 0,
            toProgress: 0.7,
            loopMode: .playOnce
        ) { [weak self] _ in
            guard let self else { return }
            self.fadeLoadingView()
        }
    }
    
    func fadeLoadingView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tabBarController?.tabBar.isHidden = false
            self.rootView.loadingView.alpha = 0.0
        })
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
                    self.homeBottomsheetView.dimView.alpha = 0
                    if let window = UIApplication.shared.keyWindowInConnectedScenes {
                        self.homeBottomsheetView.bottomsheetView.frame = CGRect(
                            x: 0,
                            y: window.frame.height,
                            width: self.homeBottomsheetView.frame.width,
                            height: self.homeBottomsheetView.bottomsheetView.frame.height
                        )
                    }
                }
            )
            homeBottomsheetView.dimView.removeFromSuperview()
            homeBottomsheetView.bottomsheetView.removeFromSuperview()
        }
    }
    
    func setBottomSheetButton(isMine: Bool, isAdmin: Bool, data: HomeFeedDTO) {
        let bottomSheetHeight = isAdmin ? 178.adjusted : 122.adjusted
        homeBottomsheetView.bottomsheetView.snp.remakeConstraints {
            $0.height.equalTo(bottomSheetHeight)
        }
        homeBottomsheetView.showSettings()
        homeBottomsheetView.deleteButton.isHidden = !isMine
        homeBottomsheetView.reportButton.isHidden = isMine
        homeBottomsheetView.banButton.isHidden = !isAdmin
        
        let target = PopupModel(
            memberID: data.memberID,
            contentType: .content,
            triggerID: data.contentID ?? -1,
            nickname: data.memberNickname,
            relatedText: data.contentTitle ?? ""
        )
        
        setBottomSheetButtonAction(isMine: isMine, data: target)
    }
    
    func setBottomSheetButtonAction(isMine: Bool, data: PopupModel) {

        let bottomSheetCancelBag = CancelBag()
        homeBottomsheetView.cancelBag = bottomSheetCancelBag
        
        if isMine {
            homeBottomsheetView.deleteButton.tapPublisher
                .sink { [weak self] in
                    self?.presentPopup(popupType: .delete, data: data)
                }
                .store(in: bottomSheetCancelBag)
        } else {
            homeBottomsheetView.reportButton.tapPublisher
                .sink { [weak self] in
                    self?.presentPopup(popupType: .report, data: data)
                }
                .store(in: bottomSheetCancelBag)
        }
        
        if loadUserData()?.isAdmin ?? false {
            homeBottomsheetView.banButton.tapPublisher
                .sink { [weak self] in
                    self?.presentPopup(popupType: .ban, data: data)
                }
                .store(in: bottomSheetCancelBag)
        }
    }
    
    private func presentPopup(popupType: PopupViewType, data: PopupModel) {
        removeBottomsheetView()
        let popupViewController = HomePopupViewController(
            viewModel: PopupViewModel(data: data),
            popupType: popupType
        )
        popupViewController.deleteButtonDidTapAction = { [weak self] triggerID, _ in
            self?.feedDeleteButtonDidTap.send(triggerID)
        }
        
        popupViewController.reportButtonDidTapAction = { [weak self] in
            self?.makeToast(toastImage: ImageLiterals.Toast.toastReport)
        }
        
        popupViewController.ghostButtonDidTapAction = { [weak self] memberID, _ in
            self?.feedGhostButtonDidTap.send(memberID)
        }
        
        popupViewController.banButtonDidTapAction = { [weak self] memberID, _ in
            guard let self else { return }
            collectionViewDidRefreshSubject.send()
            makeToast(toastImage: ImageLiterals.Toast.toastBan)
        }
        
        popupViewController.modalPresentationStyle = .overFullScreen
        popupViewController.modalTransitionStyle = .crossDissolve
        present(popupViewController, animated: true)
    }
}
