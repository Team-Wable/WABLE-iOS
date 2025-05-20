//
//  OtherProfileViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/20/25.
//

import UIKit

import SnapKit
import Then

final class OtherProfileViewController: UIViewController {
    
    // MARK: - Section & Item
    
    enum Section: CaseIterable {
        case profile
        case post
    }
    
    enum Item: Hashable {
        case profile(UserProfile)
        case content(UserContent)
        case comment(UserComment)
        case empty(ProfileEmptyCellItem)
    }
    
    // MARK: - Typealias

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - UIComponent

    private let navigationView = NavigationView(type: .page(type: .detail, title: "닉네임"))
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let cancelBag = CancelBag()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAction()
        setupNavigationBar()
    }
}

private extension OtherProfileViewController {
    
    // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(navigationView, collectionView)
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setupAction() {
        navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupDataSource() {
        let profileInfoCellRegistration = CellRegistration<ProfileInfoCell, UserProfile> { cell, indexPath, item in
            let fanTeamName = item.user.fanTeam?.rawValue ?? "LCK"
            cell.configure(
                isMyProfile: false,
                profileImageURL: item.user.profileURL,
                level: "\(item.userLevel)",
                nickname: item.user.nickname,
                introduction: "\(fanTeamName)을(를) 응원하고 있어요.\n\(item.lckYears)부터 LCK를 보기 시작했어요.",
                ghostValue: item.ghostCount,
                editButtonTapHandler: nil
            )
        }
        
        let contentCellRegistration = CellRegistration<ContentCollectionViewCell, UserContent> {
            cell, indexPath, item in
            cell.configureCell(
                info: item.contentInfo,
                authorType: .mine,
                cellType: .list,
                contentImageViewTapHandler: nil,
                likeButtonTapHandler: {
                    WableLogger.log("좋아요 눌림", for: .debug)
                    
                    // TODO: 추후 기능 연결
                },
                settingButtonTapHandler: nil,
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: nil
            )
        }
        
        let commentCellRegistration = CellRegistration<CommentCollectionViewCell, UserComment> {
            cell, indexPath, item in
            
            cell.configureCell(
                info: item.comment,
                commentType: .ripple,
                authorType: .mine,
                likeButtonTapHandler: nil,
                settingButtonTapHandler: nil,
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: nil,
                replyButtonTapHandler: nil
            )
        }
        
        let headerRegistration = SupplementaryRegistration<ProfileSegmentedHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.segmentDidChangeClosure = { [weak self] selectedIndex in
                
                // TODO: 뷰모델에 전달
                
            }
        }
        
        let emptyCellRegistration = CellRegistration<OtherProfileEmptyCell, ProfileEmptyCellItem> {
            cell, indexPath, item in
            cell.configure(currentSegment: item.segment, nickname: item.nickname)
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .profile(let profileInfo):
                return collectionView.dequeueConfiguredReusableCell(
                    using: profileInfoCellRegistration,
                    for: indexPath,
                    item: profileInfo
                )
            case .content(let content):
                return collectionView.dequeueConfiguredReusableCell(
                    using: contentCellRegistration,
                    for: indexPath,
                    item: content
                )
            case .comment(let comment):
                return collectionView.dequeueConfiguredReusableCell(
                    using: commentCellRegistration,
                    for: indexPath,
                    item: comment
                )
            case .empty(let segment):
                return collectionView.dequeueConfiguredReusableCell(
                    using: emptyCellRegistration,
                    for: indexPath,
                    item: segment
                )
            }
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = Section.allCases[indexPath.section]
            switch section {
            case .post:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                return nil
            }
        }
    }
    
    // MARK: - Helper
    
    func applySnapshot(item: ProfileViewItem) {
        guard let profileInfo = item.profileInfo else {
            return WableLogger.log("프로필 정보를 확인할 수 없음.", for: .debug)
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.profile, .post])
        snapshot.appendItems([.profile(profileInfo)], toSection: .profile)
        
        if item.currentSegment == .content {
            if item.contentList.isEmpty {
//                snapshot.appendItems([.empty(<#T##ProfileEmptyCellItem#>)], toSection: .post)
            } else {
                snapshot.appendItems(item.contentList.map { Item.content($0) }, toSection: .post)
            }
        } else {
            if item.commentList.isEmpty {
                
            } else {
                snapshot.appendItems(item.commentList.map { Item.comment($0) }, toSection: .post)
            }
        }
        
        dataSource?.apply(snapshot)
    }

    
    // MARK: - Action
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Computed Property
    
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let sectionKind = Section.allCases[sectionIndex]
            
            switch sectionKind {
            case .profile:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(336)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(336)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
                
            case .post:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(48)
                )
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                sectionHeader.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            }
        }
    }
}
