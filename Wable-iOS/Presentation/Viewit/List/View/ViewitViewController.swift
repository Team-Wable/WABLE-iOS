//
//  ViewitViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//


import UIKit

final class ViewitViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = Viewit
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let rootView = ViewitView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        setupDataSource()
        setupAction()
        loadMockData()
    }
}

// MARK: - Setup Method

private extension ViewitViewController {
    func setupDataSource() {
        let cellRegistration = CellRegistration<ViewitCell, Item> { cell, indexPath, item in
            let isBlind = item.status == .blind
            cell.configure(profileImageURL: item.userProfileURL, username: item.userNickname)
            cell.configure(
                viewitText: item.text,
                videoThumbnailImageURL: item.thumbnailURL,
                videoTitle: item.title,
                siteName: item.linkURL?.absoluteString ?? "",
                isLiked: false,
                likeCount: 0,
                isBlind: isBlind
            )
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    func setupAction() {
        writeButton.addTarget(self, action: #selector(writeButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Helper Method
    
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Action Method

    @objc func writeButtonDidTap() {
        present(CreateViewitViewController(viewModel: CreateViewitViewModel()), animated: true)
    }
}

// MARK: - Computed Property

private extension ViewitViewController {
    var collectionView: UICollectionView { rootView.collectionView }
    var refreshControl: UIRefreshControl? { rootView.collectionView.refreshControl }
    var writeButton: UIButton { rootView.writeButton }
}

// TODO: 추후 삭제

private extension ViewitViewController {
    func loadMockData() {
        let profileURL = URL(string: "https://fastly.picsum.photos/id/387/28/28.jpg?hmac=VwvoFSihTd_P4DSfzpjQlqIBbXa6BHDDAFxAPih7TjY")
        let imageURL = URL(string: "https://fastly.picsum.photos/id/98/148/84.jpg?hmac=7DON_uyl8GnjimtkXbFq8r4X9opH2ll8scJOGbE7Els")
        let mockItems: [Item] = [
            Viewit(
                userID: 1,
                userNickname: "김와블",
                userProfileURL: profileURL,
                id: 101,
                thumbnailURL: imageURL,
                linkURL: URL(string: "https://www.youtube.com/watch?v=example1"),
                title: "2024년 개발자가 알아야 할 iOS 업데이트",
                text: "요즘 개발자들에게 꼭 필요한 iOS 최신 기능들! 이 영상 완전 추천해요~",
                time: Date(),
                status: .blind,
                like: Like(status: false, count: 24)
            ),
            Viewit(
                userID: 2,
                userNickname: "개발왕",
                userProfileURL: profileURL,
                id: 102,
                thumbnailURL: imageURL,
                linkURL: URL(string: "https://www.youtube.com/watch?v=example2"),
                title: "Swift 5.10 완벽 정리 - 이것만 알면 당신도 iOS 개발자",
                text: "Swift 언어의 최신 기능들이 정말 잘 정리되어 있어요. 초보자부터 숙련자까지 모두에게 도움이 될 듯!",
                time: Date().addingTimeInterval(-3600 * 24),
                status: .normal,
                like: Like(status: true, count: 56)
            ),
            Viewit(
                userID: 3,
                userNickname: "iOS마스터",
                userProfileURL: profileURL,
                id: 103,
                thumbnailURL: imageURL,
                linkURL: URL(string: "https://www.youtube.com/watch?v=example3"),
                title: "UIKit vs SwiftUI - 2025년에도 UIKit이 필요한 이유",
                text: "최신 트렌드는 SwiftUI지만 아직 UIKit이 필요한 상황들이 많이 있어요. 이 영상이 그 이유를 잘 설명해줍니다.",
                time: Date().addingTimeInterval(-3600 * 48),
                status: .normal,
                like: Like(status: false, count: 42)
            ),
            Viewit(
                userID: 4,
                userNickname: "앱디자이너",
                userProfileURL: profileURL,
                id: 104,
                thumbnailURL: imageURL,
                linkURL: URL(string: "https://www.youtube.com/watch?v=example4"),
                title: "모바일 앱 UX/UI 디자인 트렌드 2025",
                text: "앱 디자인 트렌드가 어떻게 변하고 있는지 정말 잘 보여주는 영상입니다. 개발자와 디자이너 모두에게 추천!",
                time: Date().addingTimeInterval(-3600 * 72),
                status: .blind,
                like: Like(status: false, count: 18)
            ),
            Viewit(
                userID: 5,
                userNickname: "코딩고수",
                userProfileURL: profileURL,
                id: 105,
                thumbnailURL: imageURL,
                linkURL: URL(string: "https://www.youtube.com/watch?v=example5"),
                title: "클린 아키텍처로 iOS 앱 설계하기",
                text: "MVVM, Clean Architecture에 대해 정말 쉽게 설명해주는 영상이에요. 구현 예제도 있어서 바로 적용할 수 있어요!",
                time: Date().addingTimeInterval(-3600 * 96),
                status: .normal,
                like: Like(status: true, count: 103)
            )
        ]
        
        applySnapshot(items: mockItems)
    }
}
