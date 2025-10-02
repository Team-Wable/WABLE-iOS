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
    private let didTapped: ((String) -> Void)?
    private var selectedTeam: LCKTeam?

    // MARK: - Life Cycle

    init(didTapped: ((String) -> Void)?) {
        self.didTapped = didTapped

        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.itemSize = .init(width: 166.adjustedWidth, height: 64.adjustedHeight)
            $0.minimumInteritemSpacing = 11
            $0.minimumLineSpacing = 12
        })

        setupView()
        setupDelegate()
    }

    @available(*, unavailable)
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
        guard let team else { return }
        selectedTeam = team

        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let selectedTeam,
                  let index = randomTeamList.firstIndex(of: selectedTeam)
            else { return }

            updateCellSelection(at: IndexPath(row: index, section: 0))
        }
    }

    private func updateCellSelection(at indexPath: IndexPath) {
        for (index, _) in randomTeamList.enumerated() {
            guard let cell = cellForItem(at: IndexPath(row: index, section: 0)) as? LCKTeamCollectionViewCell else { continue }
            cell.layer.borderColor = UIColor.gray300.cgColor
            cell.teamLabel.textColor = .gray700
        }

        guard let cell = cellForItem(at: indexPath) as? LCKTeamCollectionViewCell else { return }
        cell.layer.borderColor = UIColor.purple50.cgColor
        cell.teamLabel.textColor = .wableBlack
        selectItem(at: indexPath, animated: false, scrollPosition: [])
    }
}

// MARK: - UICollectionViewDelegate

extension TeamCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTeam = randomTeamList[indexPath.row]
        self.selectedTeam = selectedTeam

        updateAllCellsStyle(selectedIndexPath: indexPath)
        didTapped?(selectedTeam.rawValue)
    }
}

// MARK: - UICollectionViewDataSource

extension TeamCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomTeamList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LCKTeamCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? LCKTeamCollectionViewCell else {
            return UICollectionViewCell()
        }

        let team = randomTeamList[indexPath.row]
        configureCellContent(cell, with: team)
        configureCellStyle(cell, isSelected: selectedTeam == team)

        return cell
    }
}

// MARK: - Helper Method

private extension TeamCollectionView {
    func configureCellContent(_ cell: LCKTeamCollectionViewCell, with team: LCKTeam) {
        cell.teamLabel.text = team.rawValue
        cell.teamImageView.image = UIImage(named: team.rawValue.lowercased())
    }

    func configureCellStyle(_ cell: LCKTeamCollectionViewCell, isSelected: Bool) {
        cell.layer.borderColor = isSelected ? UIColor.purple50.cgColor : UIColor.gray300.cgColor
        cell.teamLabel.textColor = isSelected ? .wableBlack : .gray700
    }

    func updateAllCellsStyle(selectedIndexPath: IndexPath) {
        for cell in visibleCells {
            guard let cell = cell as? LCKTeamCollectionViewCell else { continue }
            cell.layer.borderColor = UIColor.gray300.cgColor
            cell.teamLabel.textColor = .gray700
        }

        guard let cell = cellForItem(at: selectedIndexPath) as? LCKTeamCollectionViewCell else { return }
        cell.layer.borderColor = UIColor.purple50.cgColor
        cell.teamLabel.textColor = .wableBlack
    }
}
