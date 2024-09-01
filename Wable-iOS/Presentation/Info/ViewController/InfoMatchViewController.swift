//
//  InfoMatchViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit
import Combine

final class InfoMatchViewController: UIViewController {
    
    // MARK: - Properties
    
    var matchInfoData: [TodayMatchesDTO] = [] 
    private let viewModel: InfoMatchViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let matchView = MatchView()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = matchView
    }
    
    init(viewModel: InfoMatchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPI()
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear.send()
    }
}

// MARK: - Extensions

extension InfoMatchViewController {
    private func setUI() {
        
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {
        matchView.matchTableView.delegate = self
        matchView.matchTableView.dataSource = self
    }
    
    private func bindViewModel() {
        viewModel.matchInfoDTO
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.matchInfoData = data
                self?.matchView.matchTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - TableView Delegate

extension InfoMatchViewController: UITableViewDelegate { }
extension InfoMatchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return matchInfoData.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return matchInfoData[section - 1].games.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = matchView.matchTableView.dequeueReusableCell(withIdentifier: MatchSessionTableViewCell.identifier, for: indexPath) as? MatchSessionTableViewCell ?? MatchSessionTableViewCell()
            cell.selectionStyle = .none
            return cell

        default:
            let cell = matchView.matchTableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell ?? MatchTableViewCell()
            cell.bind(data: matchInfoData[indexPath.section - 1].games[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 77.adjusted
        default:
            return 116.adjusted
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0 :
            return 0
        default:
            return 39.adjusted
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MatchTableViewHeaderView.identifier) as? MatchTableViewHeaderView else { return nil }
        switch section {
        case 0:
            return nil
        default:
            if section == 1 {
                headerView.bind(isToday: true, date: matchInfoData[section - 1].date)
                return headerView
            } else {
                headerView.bind(isToday: false, date: matchInfoData[section - 1].date)
                return headerView
            }
        }
    }
}

// MARK: - Network

extension InfoMatchViewController {
    private func getAPI() {
        
    }
}
