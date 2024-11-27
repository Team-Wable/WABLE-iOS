//
//  InfoDetailView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit

import SnapKit

final class InfoDetailView: UIView {
    private let statusBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableBlack
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .wableBlack
        label.font = .head1
        label.numberOfLines = 0
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray500
        label.font = .caption2
        label.textAlignment = .right
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.adjusted
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.numberOfLines = 0
        label.textColor = .gray800
        return label
    }()
    
    private let bodyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    let submitOpinionButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.Info.submitOpinionButtonMediumTitle, for: .normal)
        button.setTitleColor(.sky50, for: .normal)
        button.titleLabel?.font = .body3
        button.backgroundColor = .wableBlack
        button.layer.cornerRadius = 12.adjusted
        return button
    }()
    
    let submitOpinionButtonContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Method

private extension InfoDetailView {
    func setupView() {
        backgroundColor = .wableWhite
        
        scrollView.addSubview(contentView)
        
        [imageView, bodyLabel].forEach { bodyStackView.addArrangedSubview($0) }
        
        contentView.addSubviews(titleLabel, timeLabel, bodyStackView, bottomBorder)
        
        submitOpinionButtonContainer.addSubview(submitOpinionButton)
        
        [scrollView, submitOpinionButtonContainer].forEach { stackView.addArrangedSubview($0) }
        
        addSubviews(statusBarBackgroundView, stackView)
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide

        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-4)
        }
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel).offset(4)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(52.adjusted)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(192.adjustedH)
        }
        
        bodyStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        bottomBorder.snp.makeConstraints { make in
            make.top.equalTo(bodyStackView.snp.bottom).offset(18)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(8)
        }
        
        submitOpinionButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(48.adjustedH)
        }
    }
}
