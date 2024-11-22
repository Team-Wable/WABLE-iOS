//
//  MatchView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class MatchView: UIView {
    let matchTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .wableWhite
        tableView.register(
            MatchTableViewHeaderView.self,
            forHeaderFooterViewReuseIdentifier: MatchTableViewHeaderView.identifier
        )
        tableView.register(
            MatchTableViewCell.self,
            forCellReuseIdentifier: MatchTableViewCell.identifier
        )
        tableView.register(
            MatchSessionTableViewCell.self,
            forCellReuseIdentifier: MatchSessionTableViewCell.identifier
        )
        return tableView
    }()
    
    let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgNotiEmpty
        imageView.isHidden = true
        return imageView
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

private extension MatchView {
    func setupView() {
        backgroundColor = .wableWhite
        
        addSubviews(matchTableView, emptyImageView)
    }
    
    func setupConstraints() {
        matchTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.height.equalTo(186.adjusted)
            $0.width.equalTo(198.adjusted)
            $0.center.equalToSuperview()
        }
    }
}
