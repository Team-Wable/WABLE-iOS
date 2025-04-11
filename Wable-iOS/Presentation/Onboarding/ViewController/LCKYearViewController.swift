//
//  LCKYearViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import UIKit

final class LCKYearViewController: NavigationViewController {
    
    // MARK: - Property
    
    var isPullDownEnabled = false
    
    // MARK: - UIComponent
    
    private let rootView = LCKYearView()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
        setupDelegate()
    }
}

// MARK: - Private Extension

private extension LCKYearViewController {
    
    // MARK: - Setup
    
    func setupView() {
        view.addSubview(rootView)
    }
    
    func setupConstraint() {
        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupAction() {
        rootView.pullDownButton.addTarget(self, action: #selector(pullDownButtonDidTap), for: .touchUpInside)
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
    
    func setupDelegate() {
        rootView.yearCollectionView.dataSource = self
        rootView.yearCollectionView.delegate = self
    }
    
    // MARK: - @objc Method
    
    @objc func pullDownButtonDidTap() {
        guard var configuration = rootView.pullDownButton.configuration else {
            return
        }
        
        configuration.image = isPullDownEnabled ? .btnDropdownDown : .btnDropdownUp
        
        rootView.yearCollectionView.isHidden = isPullDownEnabled
        rootView.pullDownButton.configuration = configuration
        
        if !isPullDownEnabled {
            self.rootView.yearCollectionView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.rootView.yearCollectionView.isHidden = false
                self.rootView.yearCollectionView.alpha = 1
            })
        }
        
        isPullDownEnabled.toggle()
    }
    
    @objc func nextButtonDidTap() {
        guard let pullDownButtonLabel = rootView.pullDownButton.titleLabel?.text,
              let lckYear = Int(pullDownButtonLabel)
        else {
            return
        }
        
        navigationController?.pushViewController(LCKTeamViewController(lckYear: lckYear), animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension LCKYearViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for visibleCell in collectionView.visibleCells {
            if let yearCell = visibleCell as? LCKYearCollectionViewCell {
                yearCell.backgroundColor = .clear
                yearCell.yearLabel.textColor = .black
            }
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LCKYearCollectionViewCell else {
            return
        }
        
        cell.backgroundColor = .purple10
        cell.yearLabel.attributedText = cell.yearLabel.text?.pretendardString(with:  .body1)
        cell.yearLabel.textColor = .purple50
        
        rootView.pullDownButton.configuration?.attributedTitle = cell.yearLabel.text?
            .pretendardString(with: .body1)
    }
}

// MARK: - UICollectionViewDataSource

extension LCKYearViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Calendar.current.component(.year, from: Date()) - 2012 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LCKYearCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? LCKYearCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.yearLabel.attributedText = String(2012 + indexPath.row).pretendardString(with:  .body2)
        
        return cell
    }
}
