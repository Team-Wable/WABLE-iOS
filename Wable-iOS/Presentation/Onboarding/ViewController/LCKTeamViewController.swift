//
//  LCKTeamViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

final class LCKTeamViewController: NavigationViewController {
    
    // MARK: - Property
    
    private let randomTeamList: [LCKTeam] = [.t1, .gen, .bro, .drx, .dk, .kt, .ns, .bfx, .hle, .dnf].shuffled()
    
    // MARK: - UIComponent
    
    private let rootView = LCKTeamView()
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDelegate()
        setupAction()
    }
}

// MARK: - Private Extension

private extension LCKTeamViewController {
    func setupView() {
        view.addSubview(rootView)
    }
    
    func setupConstraint() {
        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupDelegate() {
        rootView.teamCollectionView.delegate = self
        rootView.teamCollectionView.dataSource = self
    }
    
    func setupAction() {
        rootView.skipButton.addTarget(self, action: #selector(skipButtonDidTap), for: .touchUpInside)
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - @objc Method

    @objc func skipButtonDidTap() {
        // TODO: 좋아하는 팀 LCK로 설정하는 로직 필요
        
        navigationController?.pushViewController(ProfileRegisterViewController(type: .flow), animated: true)
    }
    
    @objc func nextButtonDidTap() {
        // TODO: 좋아하는 팀 선택된 버튼 팀으로 설정하는 로직 필요
        
        navigationController?.pushViewController(ProfileRegisterViewController(type: .flow), animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension LCKTeamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? LCKTeamCollectionViewCell else { return }
            
            cell.layer.borderColor = UIColor.gray300.cgColor
            cell.teamLabel.textColor = .gray700
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LCKTeamCollectionViewCell else { return }
        
        cell.layer.borderColor = UIColor.purple50.cgColor
        cell.teamLabel.textColor = .wableBlack
        
        rootView.nextButton.updateStyle(.primary)
        rootView.nextButton.isUserInteractionEnabled = true
    }
}

// MARK: - UICollectionViewDataSource

extension LCKTeamViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LCKTeamCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? LCKTeamCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.teamLabel.text = randomTeamList[indexPath.row].rawValue
        cell.teamLabel.textColor = .gray700
        cell.teamImageView.image = UIImage(named: randomTeamList[indexPath.row].rawValue.lowercased())
        
        return cell
    }
}
