//
//  InfoMatchViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

final class InfoMatchViewController: UIViewController {
    
    // MARK: - Properties
    
    let dummyData: [TodayMatchesDTO] = [TodayMatchesDTO(date: "08.20 (목)",
                                                        games: [Game(gameDate: "17:00",
                                                                     aTeamName: "T1",
                                                                     aTeamScore: 2,
                                                                     bTeamName: "GEN",
                                                                     bTeamScore: 3,
                                                                     gameStatus: "TERMINATION"),
                                                                Game(gameDate: "21:00",
                                                                     aTeamName: "FOX",
                                                                     aTeamScore: 4,
                                                                     bTeamName: "BRO",
                                                                     bTeamScore: 5,
                                                                     gameStatus: "PROGRESS"),
                                                                Game(gameDate: "22:00",
                                                                     aTeamName: "GEN",
                                                                     aTeamScore: 3,
                                                                     bTeamName: "BRO",
                                                                     bTeamScore: 7,
                                                                     gameStatus: "SCHEDULED")]),
                                        TodayMatchesDTO(date: "08.21 (금)",
                                                        games: [Game(gameDate: "17:00",
                                                                     aTeamName: "T1",
                                                                     aTeamScore: 2,
                                                                     bTeamName: "GEN",
                                                                     bTeamScore: 3,
                                                                     gameStatus: "SCHEDULED"),
                                                                Game(gameDate: "21:00",
                                                                     aTeamName: "TBD",
                                                                     aTeamScore: 0,
                                                                     bTeamName: "TBD",
                                                                     bTeamScore: 0,
                                                                     gameStatus: "SCHEDULED"),
                                                                Game(gameDate: "22:00",
                                                                     aTeamName: "TBD",
                                                                     aTeamScore: 0,
                                                                     bTeamName: "TBD",
                                                                     bTeamScore: 0,
                                                                     gameStatus: "SCHEDULED")])]
    
    // MARK: - UI Components
    
    private let matchView = MatchView()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = matchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPI()
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
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
}

// MARK: - TableView Delegate

extension InfoMatchViewController: UITableViewDelegate { }
extension InfoMatchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dummyData.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return dummyData[section - 1].games.count
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
            cell.bind(data: dummyData[indexPath.section - 1].games[indexPath.row])
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
                headerView.bind(isToday: true, date: dummyData[section - 1].date)
                return headerView
            } else {
                headerView.bind(isToday: false, date: dummyData[section - 1].date)
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
