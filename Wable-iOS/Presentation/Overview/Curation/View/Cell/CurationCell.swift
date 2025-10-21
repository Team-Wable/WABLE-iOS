//
//  CurationCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/16/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class CurationCell: UICollectionViewCell {

    // MARK: - UIComponents

    private let profileImageView = UIImageView(image: .logoSymbolSmall).then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }

    private let authorLabel = UILabel().then {
        $0.attributedText = "와블 큐레이터".pretendardString(with: .body3)
        $0.textColor = .wableBlack
    }

    private let createdAtLabel = UILabel().then {
        $0.attributedText = "".pretendardString(with: .caption4)
        $0.textColor = .gray500
    }
    
    private let cardButton = UIButton().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray200.cgColor
        $0.backgroundColor = .gray100
    }

    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }

    private let descriptionView = UIView(backgroundColor: UIColor("F7F7F7")).then {
        $0.isUserInteractionEnabled = false
    }
    
    private let titleLabel = UILabel().then {
        $0.attributedText = "".pretendardString(with: .body3)
        $0.textColor = .wableBlack
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let siteNameLabel = UILabel().then {
        $0.attributedText = "".pretendardString(with: .body4)
        $0.textColor = .gray600
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let openIconImageView = UIImageView(image: .btnCuration).then {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
    }

    private let pressedOverlay = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        $0.alpha = 0
        $0.isUserInteractionEnabled = false
    }

    // MARK: - Properties

    private var onTapCard: (() -> Void)?

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraint()
        setupActions()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        onTapCard = nil
        pressedOverlay.alpha = 0
    }
    
    func configure(
        createdAt: String,
        thumbnailURL: URL,
        title: String,
        siteName: String,
        onTap: @escaping () -> Void
    ) {
        createdAtLabel.text = "· \(createdAt)"
        titleLabel.text = title
        siteNameLabel.text = siteName
        onTapCard = onTap

        thumbnailImageView.kf.setImage(with: thumbnailURL) { [weak self] result in
            switch result {
            case .success:
                self?.thumbnailImageView.isHidden = false
            case .failure:
                self?.thumbnailImageView.isHidden = false
            }
        }
    }
}

// MARK: - Setup Method

private extension CurationCell {
    func setupView() {
        contentView.addSubviews(
            profileImageView,
            authorLabel,
            createdAtLabel,
            cardButton
        )

        cardButton.addSubviews(
            thumbnailImageView,
            descriptionView,
            pressedOverlay
        )
        
        descriptionView.addSubviews(
            titleLabel,
            siteNameLabel,
            openIconImageView
        )
    }
    
    func setupConstraint() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.adjustedWidthEqualTo(28)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(profileImageView.snp.width)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }

        createdAtLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(authorLabel.snp.trailing).offset(8)
        }

        cardButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }

        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(openIconImageView.snp.leading).offset(-16)
        }

        siteNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalTo(openIconImageView.snp.leading).offset(-16)
        }

        openIconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.adjustedWidthEqualTo(32)
            make.adjustedHeightEqualTo(32)
        }

        descriptionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        pressedOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupActions() {
        cardButton.addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
        cardButton.addTarget(self, action: #selector(cardTouchDown), for: [.touchDown])
        cardButton.addTarget(self, action: #selector(cardTouchUpCancel), for: [.touchDragExit, .touchCancel, .touchUpOutside])
    }

    @objc func cardTapped() {
        animatePressed(false)
        onTapCard?()
    }

    @objc func cardTouchDown() {
        animatePressed(true)
    }

    @objc func cardTouchUpCancel() {
        animatePressed(false)
    }

    func animatePressed(_ pressed: Bool) {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.pressedOverlay.alpha = pressed ? 1 : 0
        }
    }
}
