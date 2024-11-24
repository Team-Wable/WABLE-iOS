//
//  MatchTableViewHeaderView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class MatchTableViewHeaderView: UITableViewHeaderFooterView {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "07. 18 (목)"
        label.font = .head2
        label.textColor = .wableBlack
        return label
    }()
    
    // MARK: - Initializer
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension MatchTableViewHeaderView {
    func bind(isToday: Bool, date: String) {
        if isToday {
            dateLabel.text = StringLiterals.Info.today + date
            dateLabel.asColor(targetString: StringLiterals.Info.today, color: .info)
        } else {
            dateLabel.text = date
        }
    }
}

// MARK: - Private Method

private extension MatchTableViewHeaderView {
    func setupView() {
        contentView.addSubview(dateLabel)
    }
    
    func setupConstraints() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
    }
}
