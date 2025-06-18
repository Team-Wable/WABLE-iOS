//
//  TeamCollectionView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 6/18/25.
//

import UIKit

final class TeamCollectionView: UICollectionView {
    
    // MARK: - Property

    let randomTeamList: [LCKTeam] = [.t1, .gen, .bro, .drx, .dk, .kt, .ns, .bfx, .hle, .dnf].shuffled()
    private let tappedHandler: ((String) -> Void)?
    private var selectedTeam: LCKTeam? // 선택된 팀을 저장
    
    // MARK: - LifeCycle

    init(cellDidTapped: ((String) -> Void)?) {
        self.tappedHandler = cellDidTapped
        
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.itemSize = .init(width: 166.adjustedWidth, height: 64.adjustedHeight)
            $0.minimumInteritemSpacing = 11
            $0.minimumLineSpacing = 12
        })
        
        setupView()
        setupDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Method

private extension TeamCollectionView {
    func setupView() {
        register(
            LCKTeamCollectionViewCell.self,
            forCellWithReuseIdentifier: LCKTeamCollectionViewCell.reuseIdentifier
        )
        isScrollEnabled = false
    }
    
    func setupDelegate() {
        delegate = self
        dataSource = self
    }
}

// MARK: - Helper Method

extension TeamCollectionView {
    func selectInitialTeam(team: LCKTeam?) {
        guard let team = team else { return }
        
        selectedTeam = team
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let selectedTeam = selectedTeam,
                  let index = randomTeamList.firstIndex(of: selectedTeam) else {
                return
            }
            
            let indexPath = IndexPath(row: index, section: 0)
            
            for (index, _) in randomTeamList.enumerated() {
                if let cell = cellForItem(at: IndexPath(row: index, section: 0)) as? LCKTeamCollectionViewCell {
                    cell.layer.borderColor = UIColor.gray300.cgColor
                    cell.teamLabel.textColor = .gray700
                }
            }
            
            if let cell = cellForItem(at: indexPath) as? LCKTeamCollectionViewCell {
                cell.layer.borderColor = UIColor.purple50.cgColor
                cell.teamLabel.textColor = .wableBlack
            }
            
            selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TeamCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTeam = randomTeamList[indexPath.row]
        self.selectedTeam = selectedTeam
        
        for cell in collectionView.visibleCells {
            guard let cell = cell as? LCKTeamCollectionViewCell else { return }
            
            cell.layer.borderColor = UIColor.gray300.cgColor
            cell.teamLabel.textColor = .gray700
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LCKTeamCollectionViewCell else { return }
        
        cell.layer.borderColor = UIColor.purple50.cgColor
        cell.teamLabel.textColor = .wableBlack
        
        tappedHandler?(selectedTeam.rawValue)
    }
}

extension TeamCollectionView: UICollectionViewDataSource {
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
        
        let team = randomTeamList[indexPath.row]
        cell.teamLabel.text = team.rawValue
        cell.teamImageView.image = UIImage(named: team.rawValue.lowercased())
        
        if let selectedTeam = selectedTeam, selectedTeam == team {
            cell.layer.borderColor = UIColor.purple50.cgColor
            cell.teamLabel.textColor = .wableBlack
        } else {
            cell.layer.borderColor = UIColor.gray300.cgColor
            cell.teamLabel.textColor = .gray700
        }
        
        return cell
    }
}
