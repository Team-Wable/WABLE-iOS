//
//  MatchView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

//
//  ExampleView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

import SnapKit

final class MatchView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    let matchTableView = UITableView(frame: .zero, style: .grouped)
    var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgNotiEmpty
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .wableWhite
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

extension MatchView {
    private func setUI() {
        self.backgroundColor = .white
        matchTableView.separatorStyle = .none
        matchTableView.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(matchTableView,
                         emptyImageView)
    }
    
    private func setLayout() {
        matchTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.height.equalTo(186.adjusted)
            $0.width.equalTo(198.adjusted)
            $0.center.equalToSuperview()
        }
    }
    
    private func setAddTarget() {

    }
    
    private func setRegisterCell() {
        matchTableView.register(MatchTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MatchTableViewHeaderView.identifier)
        matchTableView.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        matchTableView.register(MatchSessionTableViewCell.self, forCellReuseIdentifier: MatchSessionTableViewCell.identifier)
    }
    
    private func setDataBind() {
        
    }
}
