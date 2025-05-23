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
    
    private var selectedYearIndex: Int?
    private var yearCount: Int {
        return Calendar.current.component(.year, from: .now) - Constant.startYear + 1
    }
    
    // MARK: - UIComponent
    
    private let rootView = LCKYearView()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
        setupDelegate()
        setDefaultYear()
    }
}

// MARK: - Private Extension

private extension LCKYearViewController {
    
    // MARK: - Setup
    
    func setupView() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
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
    
    func setDefaultYear() {
        let defaultIndex = yearCount - 1
        let defaultYear = Constant.startYear + defaultIndex
        
        selectedYearIndex = defaultIndex
        rootView.pullDownButton.configuration?.attributedTitle = "\(defaultYear)".pretendardString(with: .body1)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(item: defaultIndex, section: 0)
            
            self.rootView.yearCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            self.updateCellAppearance(indexPath: indexPath)
        }
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
        guard let selectedIndex = selectedYearIndex else {
            setDefaultYear()
            return
        }
        
        navigationController?.pushViewController(LCKTeamViewController(lckYear: Constant.startYear + selectedIndex), animated: true)
    }
}

// MARK: - Helper Method

private extension LCKYearViewController {
    func updateCellAppearance(indexPath: IndexPath) {
        for visibleCell in rootView.yearCollectionView.visibleCells {
            if let yearCell = visibleCell as? LCKYearCollectionViewCell {
                yearCell.backgroundColor = .clear
                yearCell.yearLabel.textColor = .wableBlack
                yearCell.yearLabel.attributedText = yearCell.yearLabel.text?.pretendardString(with: .body2)
            }
        }
        
        if let cell = rootView.yearCollectionView.cellForItem(at: indexPath) as? LCKYearCollectionViewCell {
            cell.backgroundColor = .purple10
            cell.yearLabel.attributedText = cell.yearLabel.text?.pretendardString(with: .body1)
            cell.yearLabel.textColor = .purple50
        }
    }
}


// MARK: - UICollectionViewDataSource

extension LCKYearViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedYearIndex = indexPath.item
        
        updateCellAppearance(indexPath: indexPath)
        
        rootView.pullDownButton.configuration?.attributedTitle = String(Constant.startYear + indexPath.item).pretendardString(with: .body1)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.rootView.yearCollectionView.alpha = 0
        }) { _ in
            self.rootView.yearCollectionView.isHidden = true
            self.isPullDownEnabled = false
            
            if var configuration = self.rootView.pullDownButton.configuration {
                configuration.image = .btnDropdownDown
                self.rootView.pullDownButton.configuration = configuration
            }
        }
        
        collectionView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource

extension LCKYearViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return yearCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LCKYearCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? LCKYearCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let selectedIndex = selectedYearIndex {
            let condition = indexPath.item == selectedIndex
            
            cell.backgroundColor = condition ? .purple10 : .clear
            cell.yearLabel.attributedText = String(Constant.startYear + indexPath.item).pretendardString(with: condition ? .body1 : .body2)
            cell.yearLabel.textColor = condition ? .purple50 : .wableBlack
        }
        
        return cell
    }
}

private extension LCKYearViewController {
    enum Constant {
        static let startYear: Int = 2012
    }
}
