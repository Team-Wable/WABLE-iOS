//
//  JoinLCKTeamView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

import SnapKit

final class JoinLCKTeamView: UIView {
    
    // MARK: - Properties
    
    var lckTeamData: [(String, String)] = [
        ("T1", "t1"),
        ("GEN", "gen"),
        ("BRO", "bro"),
        ("DRX", "drx"),
        ("DK", "dk"),
        ("KT", "kt"),
        ("FOX","fox"),
        ("NS", "ns"),
        ("KDF","kdf"),
        ("HLE","hle"),
    ]

    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = StringLiterals.Join.JoinLCKTeamTitle
        title.textColor = .wableBlack
        title.font = .head0
        return title
    }()
    
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Join.JoinLCKTeamSubTitle
        label.textColor = .gray600
        label.font = .body2
        label.numberOfLines = 2
        label.setTextWithLineHeight(text: label.text, lineHeight: 27.adjusted, alignment: .left)
        return label
    }()
    
    let gridStackView: UIStackView = {
        let gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.spacing = 12.adjusted
        gridStackView.distribution = .fillEqually
        return gridStackView
    }()
    
    private var selectedButton: UIButton?
    
    let noLCKTeamButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.Join.JoinLCKTeamNoneButtonTitle, for: .normal)
        button.setTitleColor(.gray600, for: .normal)
        button.titleLabel?.font = .body2
        return button
    }()
    
    let nextButton: UIButton = {
        let button = WableButton(type: .large, title: StringLiterals.Join.JoinNextButtonTitle, isEnabled: false)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 랜덤으로 섞기
        lckTeamData.shuffle()
        
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension JoinLCKTeamView {
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         subTitleLabel,
                         gridStackView,
                         noLCKTeamButton,
                         nextButton)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(110.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6.adjustedH)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        gridStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(20.adjustedH)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(368.adjusted)
        }
        
        // 버튼을 2열씩 배치
        for i in stride(from: 0, to: lckTeamData.count, by: 2) {
            let rowStackView = UIStackView(arrangedSubviews: [
                createButton(title: lckTeamData[i].0, imageName: lckTeamData[i].1),
                createButton(title: lckTeamData[i+1].0, imageName: lckTeamData[i+1].1)
            ])
            rowStackView.axis = .horizontal
            rowStackView.spacing = 11.adjusted
            rowStackView.distribution = .fillEqually
            gridStackView.addArrangedSubview(rowStackView)
        }
        
        noLCKTeamButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-23.adjusted)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
        }
    }
    
    private func createButton(title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray700, for: .normal)
        button.setImage(.load(name: imageName).withRenderingMode(.alwaysOriginal), for: .normal)
        button.titleLabel?.font = .body1
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 32.adjusted
        button.layer.borderWidth = 1.adjusted
        button.layer.borderColor = UIColor.gray300.cgColor
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(lckTeamButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc private func lckTeamButtonTapped(_ sender: UIButton) {
        // 이전에 선택된 버튼의 선택 해제
        selectedButton?.isSelected = false
        selectedButton?.setTitleColor(.gray700, for: .normal)
        selectedButton?.layer.borderColor = UIColor.gray300.cgColor

        sender.setTitleColor(.wableBlack, for: .normal)
        sender.layer.borderColor = UIColor.purple50.cgColor
        
        selectedButton = sender
        
        nextButton.isEnabled = true
    }
}
