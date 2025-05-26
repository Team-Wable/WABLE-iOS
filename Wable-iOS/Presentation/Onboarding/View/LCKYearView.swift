//
//  LCKYearView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import UIKit

final class LCKYearView: UIView {
    
    // MARK: - Property
    
    let lckYears = Array(2012...Calendar.current.component(.year, from: Date()))
    
    // MARK: - UIComponent
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Onboarding.yearSheetTitle.pretendardString(with: .head0)
        $0.textColor = .wableBlack
    }
    
    private let descriptionLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Onboarding.yearSheetMessage.pretendardString(with: .body2)
        $0.textColor = .gray600
    }
    
    private let viewingYearLabel: UILabel = UILabel().then {
        $0.attributedText = "시청 시작 연도".pretendardString(with: .caption3)
        $0.textColor = .purple50
    }
    
    lazy var pullDownButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.contentInsets = .init(top: 8, leading: 20, bottom: 8, trailing: 8)
        $0.configuration?.attributedTitle = "\(Calendar.current.component(.year, from: Date()))"
            .pretendardString(with: .body1)
        $0.configuration?.image = .btnDropdownDown
        $0.configuration?.imagePlacement = .trailing
        $0.configuration?.imagePadding = 231
        $0.tintColor = .wableBlack
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray300.cgColor
    }
    
    lazy var yearCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.itemSize = .init(width: 318.adjustedWidth, height: 54.adjustedHeight)
            $0.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
            $0.minimumLineSpacing = 8
        }).then {
            $0.register(LCKYearCollectionViewCell.self, forCellWithReuseIdentifier: LCKYearCollectionViewCell.reuseIdentifier)
            $0.isHidden = true
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.gray300.cgColor
        }
    
    let nextButton: WableButton = WableButton(style: .primary).then {
        $0.configuration?.attributedTitle = "다음으로".pretendardString(with: .head2)
    }
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension

private extension LCKYearView {
    
    // MARK: - Setup Method
    
    func setupView() {
        backgroundColor = .wableWhite
        addSubviews(
            titleLabel,
            descriptionLabel,
            viewingYearLabel,
            pullDownButton,
            yearCollectionView,
            nextButton
        )
    }
    
    func setupConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(16)
        }
        
        viewingYearLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(23)
            $0.leading.equalToSuperview().inset(16)
        }
        
        pullDownButton.snp.makeConstraints {
            $0.top.equalTo(viewingYearLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(60)
        }
        
        yearCollectionView.snp.makeConstraints {
            $0.top.equalTo(pullDownButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(314)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(56)
        }
    }
}
