//
//  NotificationActivityView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/21/24.
//

import UIKit

import SnapKit

final class NotificationContentView: UIView {
    let notiTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .wableWhite
        tableView.refreshControl = UIRefreshControl()
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        return tableView
    }()
    
    let noNotiLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Notification.noNoti
        label.isHidden = true
        label.font = .body2
        label.textColor = .gray500
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Method

private extension NotificationContentView {
    func setupView() {
        backgroundColor = .white
        
        addSubviews(notiTableView, noNotiLabel)
    }
    
    func setupConstraints() {
        notiTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        noNotiLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
