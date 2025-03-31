//
//  AnnouncementDetailView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/23/25.
//

import UIKit

import SnapKit
import Then

final class AnnouncementDetailView: UIView {
    
    // MARK: - UIComponent
    
    private let statusBarBackgroundView: UIView = .init(backgroundColor: .wableBlack)
    
    private let navigationBackgroundView: UIView = .init(backgroundColor: .wableBlack)
    
    let navigationBackButton: UIButton = .init().then {
        $0.setImage(.icBack.withTintColor(.wableWhite), for: .normal)
    }
    
    let navigationTitleLabel: UILabel = .init().then {
        $0.attributedText = "타이틀".pretendardString(with: .body1)
        $0.textColor = .wableWhite
    }
    
    private let contentStackView: UIStackView = .init(axis: .vertical).then {
        $0.spacing = 12
        $0.alignment = .fill
    }
    
    private let scrollView: UIScrollView = .init()
    
    private let containerView: UIView = .init()
    
    let titleLabel: UILabel = .init().then {
        $0.attributedText = "제목".pretendardString(with: .head1)
        $0.numberOfLines = 0
    }
    
    let timeLabel: UILabel = .init().then {
        $0.attributedText = "1분전".pretendardString(with: .caption2)
        $0.textAlignment = .right
        $0.textColor = .gray500
    }
    
    private let bodyStackView: UIStackView = .init(axis: .vertical).then {
        $0.spacing = 8
    }
    
    let imageView: UIImageView = .init().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }
    
    let bodyTextView: UITextView = .init().then {
        $0.attributedText = "내용".pretendardString(with: .body2)
        $0.textColor = .gray800
        $0.dataDetectorTypes = .link
        $0.isEditable = false
        $0.isSelectable = true
        $0.isScrollEnabled = false
    }
    
    private let divisionLine: UIView = .init(backgroundColor: .gray200)
    
    let submitButtonContainerView: UIView = .init().then {
        $0.isHidden = true
    }
    
    let submitButton: WableButton = .init(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = "와블에 대한 의견 남기러 가기".pretendardString(with: .body3)
        config?.baseForegroundColor = .sky50
        $0.configuration = config
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Method

private extension AnnouncementDetailView {
    func setupView() {
        backgroundColor = .wableWhite
        
        navigationBackgroundView.addSubviews(
            navigationBackButton,
            navigationTitleLabel
        )
        
        bodyStackView.addArrangedSubviews(
            imageView,
            bodyTextView
        )
        
        containerView.addSubviews(
            titleLabel,
            timeLabel,
            bodyStackView,
            divisionLine
        )
        
        scrollView.addSubview(containerView)
        
        submitButtonContainerView.addSubview(submitButton)
        
        contentStackView.addArrangedSubviews(
            scrollView,
            submitButtonContainerView
        )
        
        addSubviews(
            statusBarBackgroundView,
            navigationBackgroundView,
            contentStackView
        )
    }
    
    func setupConstraint() {
        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        navigationBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(60)
        }
        
        navigationBackButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.adjustedWidthEqualTo(32)
            make.adjustedHeightEqualTo(32)
        }
        
        navigationTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(navigationBackgroundView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeArea)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-60)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        bodyStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        imageView.snp.makeConstraints { make in
            make.adjustedHeightEqualTo(192)
        }
        
        divisionLine.snp.makeConstraints { make in
            make.top.equalTo(bodyStackView.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(8)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.adjustedHeightEqualTo(48)
        }
    }
}
