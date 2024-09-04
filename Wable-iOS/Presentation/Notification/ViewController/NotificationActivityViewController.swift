//
//  NotificationActivityViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//


import UIKit
import Combine

extension Notification.Name {
    static let didRequestPushDetailViewController = Notification.Name("didRequestPushDetailViewController")
    static let didRequestPushWriteFeedViewController = Notification.Name("didRequestPushWriteFeedViewController")
}

final class NotificationActivityViewController: UIViewController {
    
    // MARK: - Properties
    
    private var paginationNotiActivityData: [ActivityNotificationDTO] = []
    var notiActivityData: [ActivityNotificationDTO] = [] {
        didSet {
            if notiActivityData.count == 0 {
                rootView.notiTableView.isHidden = true
                rootView.noNotiLabel.isHidden = false
            } else {
                rootView.notiTableView.isHidden = false
                rootView.noNotiLabel.isHidden = true
            }
        }
    }
    private let viewModel: NotificationActivityViewModel
    private var cancellables = Set<AnyCancellable>()
    private var feedContentData: HomeFeedDTO?
    
    // MARK: - UI Components
    
    private let rootView = NotificationContentView()
    private let refreshControl = UIRefreshControl()
    
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        setRefreshControl()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear.send()
    }
    
    init(viewModel: NotificationActivityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension NotificationActivityViewController {
    private func setUI() {
        
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {
        rootView.notiTableView.delegate = self
        rootView.notiTableView.dataSource = self
    }
    
    private func bindViewModel() {
        viewModel.notiActivityDTO
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.notiActivityData = data
                self?.rootView.notiTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.paginationNotiActivityDTO
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.paginationNotiActivityData = data
                self?.notiActivityData.append(contentsOf: self?.paginationNotiActivityData ?? [])
            }
            .store(in: &cancellables)
        
        viewModel.writeFeedCellDidTapped
            .receive(on: DispatchQueue.main)
            .sink { _ in
                NotificationCenter.default.post(name: .didRequestPushWriteFeedViewController, object: nil)
            }
            .store(in: &cancellables)
        
        viewModel.homeFeedTopInfoDTO
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (data, contentID) in
                self?.feedContentData = data
                NotificationCenter.default.post(name: .didRequestPushDetailViewController, object: nil, userInfo: ["data": data, "contentID": contentID])
            }
            .store(in: &cancellables)
    }
    
    private func setRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        rootView.notiTableView.refreshControl = self.refreshControl
    }
    
    @objc
    private func didPullToRefresh() {
        viewModel.viewWillAppear.send()
        self.perform(#selector(finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    private func finishedRefreshing() {
        self.refreshControl.endRefreshing()
    }

}

// MARK: - TableView Delegate

extension NotificationActivityViewController: UITableViewDelegate { }
extension NotificationActivityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notiActivityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = rootView.notiTableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell ?? NotificationTableViewCell()
        cell.selectionStyle = .none
        cell.bindForActivity(data: notiActivityData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.adjusted
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let notiType = NotiActivityText(rawValue: notiActivityData[indexPath.row].notificationTriggerType) {
            switch notiType {
            case .actingContinue:
                viewModel.writeFeedCellDidTapped.send()
            case .userBan:
                return
            default:
                viewModel.notiCellDidTapped.send(notiActivityData[indexPath.row].notificationTriggerID)
            }
        } else {
            print("알 수 없는 알림 유형입니다.")
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == rootView.notiTableView {
            if notiActivityData.count >= 15 && (scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height) {
                let lastNotificationId = notiActivityData.last?.notificationID ?? -1
                if lastNotificationId != -1 {
                    print("==========================pagination 작동==========================")
                    viewModel.cursor = lastNotificationId
                    viewModel.paginationDidAction.send()
                    DispatchQueue.main.async {
                        self.rootView.notiTableView.reloadData()
                    }
                }
            }
        }
    }
}
