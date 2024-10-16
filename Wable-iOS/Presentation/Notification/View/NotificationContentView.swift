//
//  NotificationActivityView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/21/24.
//

import UIKit

import SnapKit

final class NotificationContentView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    var notiTableView = UITableView()
    var noNotiLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Notification.noNoti
        label.isHidden = true
        label.font = .body2
        label.textColor = .gray500
        return label
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray400
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
        setRegisterCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension NotificationContentView {
    private func setUI() {
        self.backgroundColor = .white
        notiTableView.separatorStyle = .none
        notiTableView.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(notiTableView, noNotiLabel)
    }
    
    private func setLayout() {
        notiTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        noNotiLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setAddTarget() {

    }
    
    private func setRegisterCell() {
        notiTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
    }
    
    private func setDataBind() {
        
    }
}
