//
//  HomeView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

import SnapKit

final class HomeView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    private var homeTabView = HomeTabView()
    var feedTableView = UITableView()
    var writeFeedButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnWrite, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
        setRegisterCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension HomeView {
    private func setUI() {
        self.backgroundColor = .wableWhite
        self.feedTableView.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(homeTabView,
                         feedTableView,
                         writeFeedButton)
    }
    
    private func setLayout() {
        homeTabView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
        }
        
        feedTableView.snp.makeConstraints {
            $0.top.equalTo(homeTabView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        writeFeedButton.snp.makeConstraints {
            $0.height.width.equalTo(60.adjusted)
            $0.bottom.trailing.equalToSuperview().inset(16.adjusted)
        }
    }
    
    private func setRegisterCell() {
        feedTableView.register(HomeFeedTableViewCell.self, forCellReuseIdentifier: HomeFeedTableViewCell.identifier)
    }
    
    private func setDataBind() {
        
    }
}
