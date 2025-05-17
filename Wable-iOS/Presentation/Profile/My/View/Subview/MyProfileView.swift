//
//  MyProfileView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then

final class MyProfileView: UIView {
    let navigationView = NavigationView(type: .page(type: .profile, title: "이름"))
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    let contentEmptyView = UIView().then {
        $0.isHidden = true
    }
    
    let contentEmptyLabel = UILabel().then {
        $0.attributedText = "이름님, 아직 글을 작성하지 않았네요!\n왠지 텅빈 게시글이 허전하게 느껴져요."
            .pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.numberOfLines = 0
    }
    
    let contentEmptyWriteButton = WableButton(style: .primary).then {
        var config = $0.configuration
        config?.attributedTitle = "글 작성하러 가기".pretendardString(with: .body1)
        $0.configuration = config
    }
    
    private let divisionLine = UIView(backgroundColor: .gray200)
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .wableWhite
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyProfileView {
    func setupView() {
        contentEmptyView.addSubviews(contentEmptyLabel, contentEmptyWriteButton)
        
        addSubviews(navigationView, collectionView, contentEmptyView, divisionLine)
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
        }
        
        contentEmptyLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(contentEmptyWriteButton.snp.top).offset(-24)
        }
        
        contentEmptyWriteButton.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.adjustedHeightEqualTo(48)
        }
        
        contentEmptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeArea).offset(-48)
        }
        
        divisionLine.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeArea)
            make.height.equalTo(1)
        }
    }
}
