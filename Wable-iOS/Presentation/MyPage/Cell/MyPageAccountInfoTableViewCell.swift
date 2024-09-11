//
//  MyPageAccountInfoTableViewCell.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/20/24.
//

import UIKit

import SnapKit

final class MyPageAccountInfoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "MyPageAccountInfoTableViewCell"
    
    // MARK: - UI Components
    
    let infoTitle: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.textColor = .gray600
        return label
    }()
    
    let infoContent: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.textColor = .wableBlack
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Life Cycles

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }
}

// MARK: - Extensions

extension MyPageAccountInfoTableViewCell {
    func setUI() {
        
    }
    
    func setHierarchy() {
        self.addSubviews(infoTitle,
                         infoContent)
    }
    
    func setLayout() {
        infoTitle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(26.adjusted)
        }
        
        infoContent.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(159.adjusted)
            $0.trailing.equalToSuperview().inset(26.adjusted)
        }
    }
    
    func setAddTarget() {
        
    }
}
