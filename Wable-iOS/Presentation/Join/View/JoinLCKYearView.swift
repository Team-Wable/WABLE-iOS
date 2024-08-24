//
//  JoinLCKYearView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

import SnapKit

final class JoinLCKYearView: UIView {
    
    // MARK: - Properties
    
    private let years = Array(2012...2024) // 연도 범위 설정
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Join.JoinLCKYearTitle
        label.textColor = .wableBlack
        label.font = .head0
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Join.JoinLCKYearSubTitle
        label.textColor = .gray600
        label.font = .body2
        return label
    }()
    
    private let startYearLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Join.JoinLCKYearStartYear
        label.textColor = .purple50
        label.font = .caption3
        return label
    }()
    
    private let dropDownButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1.adjusted
        button.layer.borderColor = UIColor.gray300.cgColor
        return button
    }()
    
    var selectedStartYear: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Join.JoinLCKYearDefaultYear
        label.textColor = .wableBlack
        label.font = .body1
        return label
    }()
    
    private let dropDownDownImage: UIImageView = {
        let image = UIImageView()
        image.image = ImageLiterals.Button.btnDropdownDown
        return image
    }()
    
    private let dropDownUpImage: UIImageView = {
        let image = UIImageView()
        image.image = ImageLiterals.Button.btnDropdownUp
        image.isHidden = true
        return image
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isHidden = true
        scrollView.layer.cornerRadius = 8
        scrollView.layer.borderWidth = 1.adjusted
        scrollView.layer.borderColor = UIColor.gray300.cgColor
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8.adjusted
        return stackView
    }()

    private var selectedButton: UIButton?
    
    let nextButton: UIButton = {
        let button = WableButton(type: .large, title: StringLiterals.Join.JoinNextButtonTitle, isEnabled: true)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension JoinLCKYearView {
    private func setUI() {
        self.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         subTitleLabel,
                         startYearLabel,
                         dropDownButton,
                         selectedStartYear,
                         dropDownDownImage,
                         dropDownUpImage,
                         scrollView,
                         nextButton)
        
        scrollView.addSubview(stackView)
        
        for year in years {
            let button = createYearButton(title: "\(year)")
            stackView.addArrangedSubview(button)
            
            button.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(54)
            }
        }
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
        
        startYearLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(23.adjustedH)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        dropDownButton.snp.makeConstraints {
            $0.top.equalTo(startYearLabel.snp.bottom).offset(4.adjustedH)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(60.adjusted)
        }
        
        selectedStartYear.snp.makeConstraints {
            $0.centerY.equalTo(dropDownButton.snp.centerY)
            $0.leading.equalTo(dropDownButton.snp.leading).offset(20.adjusted)
        }
        
        dropDownDownImage.snp.makeConstraints {
            $0.centerY.equalTo(dropDownButton.snp.centerY)
            $0.trailing.equalTo(dropDownButton.snp.trailing).offset(-8.adjusted)
        }
        
        dropDownUpImage.snp.makeConstraints {
            $0.centerY.equalTo(dropDownButton.snp.centerY)
            $0.trailing.equalTo(dropDownButton.snp.trailing).offset(-8.adjusted)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(dropDownButton.snp.bottom).offset(10.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(314.adjusted)
        }
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6.adjusted)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(12.adjusted)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
        }
    }
    
    private func setAddTarget() {
        dropDownButton.addTarget(self, action: #selector(dropDownButtonTapped), for: .touchUpInside)
    }
    
    @objc private func dropDownButtonTapped() {
        if dropDownDownImage.isHidden == true {
            dropDownDownImage.isHidden = false
            dropDownUpImage.isHidden = true
        } else {
            dropDownDownImage.isHidden = true
            dropDownUpImage.isHidden = false
        }
        
        if scrollView.isHidden == true {
            scrollView.isHidden = false
        } else {
            scrollView.isHidden = true
        }
    }
    
    private func createYearButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.wableBlack, for: .normal)
        button.titleLabel?.font = .body2
        button.contentHorizontalAlignment = .left
        button.layer.cornerRadius = 8.adjusted
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 9.adjusted, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(yearButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc private func yearButtonTapped(_ sender: UIButton) {
        // 이전에 선택된 버튼의 선택 해제
        selectedButton?.isSelected = false
        selectedButton?.setTitleColor(.wableBlack, for: .normal)
        selectedButton?.backgroundColor = .clear
        selectedButton?.titleLabel?.font = .body2

        sender.setTitleColor(.purple50, for: .normal)
        sender.backgroundColor = .purple10
        sender.titleLabel?.font = .body1
        selectedButton = sender
        
        self.selectedStartYear.text = sender.titleLabel?.text ?? "2024"
    }
}

