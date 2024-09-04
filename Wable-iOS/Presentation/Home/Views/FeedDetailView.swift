//
//  FeedDetailView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

import UIKit

import SnapKit

final class FeedDetailView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    private let topDivisionLine = UIView().makeDivisionLine()
    var feedDetailTableView = UITableView(frame: .zero, style: .plain)
    var bottomWriteView = FeedBottomWriteView()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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

extension FeedDetailView {
    private func setUI() {
        self.backgroundColor = .wableWhite
        self.feedDetailTableView.backgroundColor = .wableWhite
        feedDetailTableView.separatorStyle = .none
    }
    
    private func setHierarchy() {
        self.addSubviews(topDivisionLine, feedDetailTableView, bottomWriteView)
    }
    
    private func setLayout() {
        topDivisionLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(1.adjusted)
        }
        
        feedDetailTableView.snp.makeConstraints {
            $0.top.equalTo(topDivisionLine.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomWriteView.snp.top)
        }
        
        bottomWriteView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(62.adjusted)
        }
    }
    
    private func setAddTarget() {

    }
    
    private func setRegisterCell() {
        feedDetailTableView.register(HomeFeedTableViewCell.self, forCellReuseIdentifier: HomeFeedTableViewCell.identifier)
        feedDetailTableView.register(FeedDetailTableViewCell.self, forCellReuseIdentifier: FeedDetailTableViewCell.identifier)
    }
    
    private func setDataBind() {
        
    }
}
