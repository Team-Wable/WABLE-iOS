//
//  MatchSessionTableCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class MatchSessionTableViewCell: UITableViewCell {
    private let sessionView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .purple10
        view.layer.cornerRadius = 8.adjusted
        return view
    }()
    
    let sessionLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Info.lckSummer
        label.font = .body3
        label.textColor = .purple100
        return label
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .wableWhite
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Method

private extension MatchSessionTableViewCell {
    func setupView() {
        contentView.addSubview(sessionView)
        sessionView.addSubview(sessionLabel)
    }
    
    func setupConstraints() {
        sessionView.snp.makeConstraints {
            $0.height.equalTo(40.adjustedH)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.centerY.equalToSuperview()
        }
        
        sessionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
