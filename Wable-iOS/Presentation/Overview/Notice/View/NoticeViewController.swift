//
//  NoticeViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit

import SnapKit
import Then

final class NoticeViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    typealias Item = Announcement
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    // MARK: - UIComponent

    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let emptyLabel: UILabel = .init().then {
        $0.attributedText = "아직 작성된 공지사항이 없어요.".pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.isHidden = true
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDataSource()
    }
}

// MARK: - Setup Method

private extension NoticeViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            collectionView,
            emptyLabel
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupDataSource() {
        let noticeCellRegistration = CellRegistration<NoticeCell, Announcement> { [weak self] cell, indexPath, item in
            guard let timeText = self?.elapsedString(from: item.createdDate) else { return }
            cell.configure(title: item.title, time: timeText, body: item.text)
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: noticeCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
}

// MARK: - Private Method

private extension NoticeViewController {
    func elapsedString(from date: Date?) -> String {
        guard let date else {
            return "지금"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfMonth, .month, .year],
            from: date,
            to: now
        )
        
        if let years = components.year, years > 0 {
            return "\(years)년 전"
        } else if let months = components.month, months > 0 {
            return "\(months)달 전"
        } else if let weeks = components.weekOfMonth, weeks > 0 {
            return "\(weeks)주 전"
        } else if let days = components.day, days > 0 {
            return "\(days)일 전"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)시간 전"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)분 전"
        } else {
            return "지금"
        }
    }
}

// MARK: - Computed Property

private extension NoticeViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(96)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
