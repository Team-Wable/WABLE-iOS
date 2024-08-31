//
//  NotificationInformationViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit
import Combine

final class NotificationInformationViewController: UIViewController {
    
    // MARK: - Properties
    
    var notiInfoData: [InfoNotificationDTO] = []
    private var paginationNotiInfoData: [InfoNotificationDTO] = []
    private let viewModel: NotificationInfoViewModel
    private var cancellables = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()

    // MARK: - UI Components
    
    private let rootView = NotificationContentView()
    
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
    
    init(viewModel: NotificationInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension NotificationInformationViewController {
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
        viewModel.notiInfoDTO
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.notiInfoData = data
                self?.rootView.notiTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.paginationNotiInfoDTO
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.paginationNotiInfoData = data
                self?.notiInfoData.append(contentsOf: self?.paginationNotiInfoData ?? [])
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

extension NotificationInformationViewController: UITableViewDelegate { }
extension NotificationInformationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notiInfoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = rootView.notiTableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell ?? NotificationTableViewCell()
        cell.selectionStyle = .none
        cell.bindForInformation(data: notiInfoData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.adjusted
    }
        
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == rootView.notiTableView {
            if notiInfoData.count >= 15 && (scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height) {
                let lastNotificationId = notiInfoData.last?.infoNotificationID ?? -1
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
