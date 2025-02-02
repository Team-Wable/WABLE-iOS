//
//  NotificationActivityViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit
import Combine

// MARK: - NotificationActivityViewControllerDelegate

protocol NotificationActivityViewControllerDelegate: AnyObject {
    func pushWriteFeedViewController()
    func pushFeedDetailViewController(_ homeFeed: HomeFeedDTO, contentID: Int)
    func moveMyProfileViewController()
    func pushOtherProfileViewController(_ userID: Int)
}

// MARK: - NotificationActivityViewController

final class NotificationActivityViewController: UIViewController {
    
    typealias Item = ActivityNotificationDTO
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section {
        case main
    }
    
    // MARK: - Property
    
    weak var delegate: NotificationActivityViewControllerDelegate?
    
    private var dataSource: DataSource?
    
    private let viewModel: NotificationActivityViewModel
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private let tableViewDidSelectSubject = PassthroughSubject<Int, Never>()
    private let tableViewDidEndDragSubject = PassthroughSubject<Void, Never>()
    private let tableViewDidRefreshSubject = PassthroughSubject<Void, Never>()
    private let cellImageViewDidTapSubject = PassthroughSubject<Int, Never>()
    private let cancelBag = CancelBag()
    private let rootView = NotificationContentView()
    
    // MARK: - Initializer

    init(viewModel: NotificationActivityViewModel) {
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
        
        setupDelegate()
        setupAction()
        setupDataSource()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearSubject.send(())
    }
}

// MARK: - UITableViewDelegate

extension NotificationActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.adjusted
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewDidSelectSubject.send(indexPath.row)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == rootView.notiTableView,
              (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height
        else {
            return
        }
        
        tableViewDidEndDragSubject.send(())
    }
}

// MARK: - Private Method

private extension NotificationActivityViewController {
    func setupDelegate() {
        rootView.notiTableView.delegate = self
    }
    
    func setupAction() {
        let refreshAction = UIAction { [weak self] _ in
            self?.tableViewDidRefreshSubject.send(())
        }
        
        rootView.notiTableView.refreshControl?.addAction(refreshAction, for: .valueChanged)
    }
    
    func setupDataSource() {
        dataSource = DataSource(tableView: rootView.notiTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationTableViewCell.identifier,
                for: indexPath
            ) as? NotificationTableViewCell else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            cell.bindForActivity(data: item)
            cell.imageViewDidTapAction = { [weak self] in
                self?.cellImageViewDidTapSubject.send(indexPath.row)
            }
            
            return cell
        }
    }
    
    func applySnapshot(with items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: false)
        
        guard let refreshControl = rootView.notiTableView.refreshControl,
              refreshControl.isRefreshing
        else {
            return
        }
        
        refreshControl.endRefreshing()
    }
    
    func setupBinding() {
        let input = NotificationActivityViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            tableViewDidSelect: tableViewDidSelectSubject.eraseToAnyPublisher(),
            tableViewDidEndDrag: tableViewDidEndDragSubject.eraseToAnyPublisher(),
            tableViewDidRefresh: tableViewDidRefreshSubject.eraseToAnyPublisher(),
            cellImageViewDidTap: cellImageViewDidTapSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.activityNotifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                self?.applySnapshot(with: notifications)
                self?.rootView.notiTableView.isHidden = notifications.isEmpty
                self?.rootView.noNotiLabel.isHidden = !notifications.isEmpty
            }
            .store(in: cancelBag)
        
        output.pushToWriteView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.delegate?.pushWriteFeedViewController()
            }
            .store(in: cancelBag)
        
        output.homeFeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] homeFeed, id in
                self?.delegate?.pushFeedDetailViewController(homeFeed, contentID: id)
            }
            .store(in: cancelBag)
        
        output.moveToMyProfileView
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.delegate?.moveMyProfileViewController()
            }
            .store(in: cancelBag)
        
        output.pushToOtherProfileView
            .receive(on: RunLoop.main)
            .sink { [weak self] userID in
                self?.delegate?.pushOtherProfileViewController(userID)
            }
            .store(in: cancelBag)
    }
}
