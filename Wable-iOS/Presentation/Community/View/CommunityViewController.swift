//
//  CommunityViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit
import SafariServices

import SnapKit
import Then

final class CommunityViewController: UIViewController {
    
    // MARK: - Section & Item

    enum Section {
        case main
    }
    
    // MARK: - UIComponent

    private let navigationView = NavigationView(type: .hub(title: "커뮤니티", isBeta: true)).then {
        $0.configureView()
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let askButton = WableButton(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = Constant.askButtonTitle
            .pretendardString(with: .body3)
            .highlight(textColor: .sky50, to: "요청하기")
        $0.configuration = config
    }
    
    // MARK: - Property

    private let cancelBag = CancelBag()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
}

// MARK: - Setup Method

private extension CommunityViewController {
    func setupView() {
        view.addSubviews(
            navigationView,
            collectionView,
            askButton
        )
    }
    
    func setupConstraint() {
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(60)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        askButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.equalTo(collectionView)
            make.bottom.equalTo(safeArea).offset(-16)
            make.adjustedHeightEqualTo(48)
        }
    }
    
    func setupAction() {
        askButton.addTarget(self, action: #selector(askButtonDidTap), for: .touchUpInside)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - Action Method

private extension CommunityViewController {
    @objc func askButtonDidTap() {
        guard let url = URL(string: Constant.googleFormURLText) else { return }
        
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true)
    }
}

// MARK: - Constant

private extension CommunityViewController {
    enum Constant {
        static let askButtonTitle = "더 추가하고 싶은 게시판이 있다면? 요청하기"
        static let googleFormURLText = "https://docs.google.com/forms/d/e/1FAIpQLSf3JlBkVRPaPFSreQHaEv-u5pqZWZzk7Y4Qll9lRP0htBZs-Q/viewform"
    }
}
