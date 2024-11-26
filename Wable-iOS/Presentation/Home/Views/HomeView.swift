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
    
    private let homeTabView = HomeTabView()
    let loadingView = HomeLoadingView()
    let feedTableView = UITableView()
    let writeFeedButton: UIButton = {
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
        backgroundColor = .wableWhite
        feedTableView.backgroundColor = .wableWhite
        feedTableView.separatorStyle = .none
        loadingView.isHidden = true
    }
    
    private func setHierarchy() {
        self.addSubviews(homeTabView,
                         feedTableView,
                         writeFeedButton,
                         loadingView)
    }
    
    private func setLayout() {
        loadingView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height)
        }
        
        homeTabView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
        }
        
        feedTableView.snp.makeConstraints {
            $0.top.equalTo(homeTabView.snp.bottom).offset(-2)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        writeFeedButton.snp.makeConstraints {
            $0.height.width.equalTo(60.adjusted)
            $0.bottom.trailing.equalToSuperview().inset(16.adjusted)
        }
    }
    
    private func setRegisterCell() {
        feedTableView.register(HomeFeedTableViewCell.self, forCellReuseIdentifier: HomeFeedTableViewCell.identifier)
    }
}
