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
<<<<<<< HEAD
        
=======
>>>>>>> acfc9fc ([Feat] #126 CollectionView 구현 중간 커밋)
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
        
    }
}

// MARK: - UICollectionViewDataSource

extension LCKYearViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        
//        cell
//        
//        rootView.yearButtonList.forEach {
//            guard var configuration = $0.configuration else { return }
//            let condition: Bool = ($0 == sender)
//            
//            configuration.background.backgroundColor = condition ? .purple10 : .wableWhite
//            configuration.attributedTitle = $0.titleLabel?.text?.pretendardString(with: condition ? .body1 : .body2)
//            configuration.baseForegroundColor = condition ? .purple50 : .wableBlack
//            
//            $0.configuration = configuration
//        }
//        
//        rootView.pullDownButton.configuration?.attributedTitle = sender.titleLabel?.text?
//            .pretendardString(with: .body1)
    }
}

// MARK: - UICollectionViewDataSource

extension LCKYearViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Calendar.current.component(.year, from: Date()) - 2012
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        
        let label = UILabel().then {
            $0.attributedText = "\(Calendar.current.component(.year, from: Date()))".pretendardString(with: .body2)
            $0.textColor = .wableBlack
        }
        
        cell.addSubview(label)
        
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(9)
        }
        
        return cell
    }
}
