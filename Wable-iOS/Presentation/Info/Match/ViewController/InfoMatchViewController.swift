//
//  InfoMatchViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit
import Combine

final class InfoMatchViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: Hashable {
        case session
        case match(date: String)
    }
    
    enum Item: Hashable {
        case session(String)
        case game(Game)
    }
    
    private var dataSource: DataSource?
    
    private let viewModel: InfoMatchViewModel
    private let viewWillAppear = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    private let rootView = MatchView()
    
    // MARK: - Initializer
    
    init(viewModel: InfoMatchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupBinding()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppear.send(())
    }
}

// MARK: - UITableViewDelegate

extension InfoMatchViewController: UITableViewDelegate {
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
        guard let dataSource else {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MatchTableViewHeaderView.identifier
        ) as? MatchTableViewHeaderView
        
        let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[section]
        
        switch sectionIdentifier {
        case .session:
            return nil
        case .match(let date):
            headerView?.bind(
                isToday: viewModel.isDateToday(dateString: date),
                date: date
            )
            return headerView
        }
    }
}

// MARK: - Private Method

private extension InfoMatchViewController {
    func setupDelegate() {
        rootView.matchTableView.delegate = self
    }
    
    func setupDataSource() {
        dataSource = DataSource(tableView: rootView.matchTableView) { tableView, indexPath, item in
            switch item {
            case .session(let text):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MatchSessionTableViewCell.identifier,
                    for: indexPath
                ) as? MatchSessionTableViewCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                cell.sessionLabel.text = text
                return cell
                
            case .game(let game):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MatchTableViewCell.identifier,
                    for: indexPath
                ) as? MatchTableViewCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                cell.bind(data: game)
                return cell
            }
        }
    }
    
    func setupBinding() {
        let input = InfoMatchViewModel.Input(viewWillAppear: viewWillAppear.eraseToAnyPublisher())
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.gameType
            .receive(on: RunLoop.main)
            .sink { [weak self] gameType in
                self?.applySessionSection(gameType: gameType.lckGameType)
            }
            .store(in: cancelBag)
        
        output.matchInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] matches in
                guard let self else { return }
                
                applyMatchSections(matches: matches)
                
                rootView.matchTableView.isHidden = matches.isEmpty
                rootView.emptyImageView.isHidden = !matches.isEmpty
            }
            .store(in: cancelBag)
    }
    
    func applySessionSection(gameType: String) {
        var snapshot = dataSource?.snapshot() ?? Snapshot()
        
        if !snapshot.sectionIdentifiers.contains(.session) {
            snapshot.appendSections([.session])
        }
        
        snapshot.deleteSections([.session])
        snapshot.appendSections([.session])
        snapshot.appendItems([.session(gameType)], toSection: .session)
        
        if let sessionIndex = snapshot.indexOfSection(.session),
           sessionIndex != 0,
           let firstMatchSection = snapshot.sectionIdentifiers.first {
            snapshot.moveSection(.session, beforeSection: firstMatchSection)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func applyMatchSections(matches: [TodayMatchesDTO]) {
        var snapshot = dataSource?.snapshot() ?? Snapshot()
        
        let matchSections = snapshot.sectionIdentifiers.filter {
            if case .match = $0 { return true }
            return false
        }
        snapshot.deleteSections(matchSections)
        
        for match in matches {
            let section: Section = .match(date: match.date)
            snapshot.appendSections([section])
            
            let items: [Item] = match.games.map { .game($0) }
            snapshot.appendItems(items, toSection: section)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}
