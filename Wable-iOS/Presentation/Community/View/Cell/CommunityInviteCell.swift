//
//  CommunityInviteCell .swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class CommunityInviteCell: UICollectionViewCell {
    
    // MARK: - UIComponent

    private let baseView = CommunityCellBaseView()
    
    private let progressTitleLabel = UILabel().then {
        $0.attributedText = "진행도".pretendardString(with: .caption1)
    }
    
    private let progressImageView = UIImageView(image: .icFan)
    
    private let progressBar = UIProgressView(progressViewStyle: .bar).then {
        $0.trackTintColor = .gray200
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    // MARK: - Property
    
    var copyLinkClosure: (() -> Void)?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        communityImageView.image = nil
        copyLinkClosure = nil
        resetCopyLinkButton()
    }
    
    func configure(
        image: UIImage?,
        title: String,
        progress: Float,
        progressBarColor: UIColor
    ) {
        communityImageView.image = image
        
        titleLabel.text = title
        
        progressBar.progressTintColor = progressBarColor
        progressBar.setProgress(progress, animated: true)
    }
}

// MARK: - Helper Method

private extension CommunityInviteCell {
    func resetCopyLinkButton() {
        var config = copyLinkButton.configuration
        config?.attributedTitle = Constant.defaultTitle.pretendardString(with: .body3)
        config?.image = nil
        copyLinkButton.configuration = config
    }
    
    func showCopyLinkCompletedState() {
        var config = copyLinkButton.configuration
        config?.attributedTitle = Constant.copyLinkCompletedTitle.pretendardString(with: .body3)
        config?.image = .icCheck
        config?.imagePlacement = .leading
        copyLinkButton.configuration = config
    }
}

// MARK: - Setup Method

private extension CommunityInviteCell {
    func setupView() {
        contentView.addSubviews(
            baseView,
            progressTitleLabel,
            progressImageView,
            progressBar
        )
        
        resetCopyLinkButton()
    }
    
    func setupConstraint() {
        baseView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview()
        }
        
        progressTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(baseView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
        }
        
        progressImageView.snp.makeConstraints { make in
            make.centerY.equalTo(progressTitleLabel)
            make.leading.equalTo(progressTitleLabel.snp.trailing)
            make.adjustedWidthEqualTo(16)
            make.height.equalTo(progressImageView.snp.width)
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(progressTitleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.adjustedHeightEqualTo(12)
        }
    }
    
    func setupAction() {
        copyLinkButton.addTarget(self, action: #selector(copyLinkButtonDidTap(_:)), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension CommunityInviteCell {
    @objc func copyLinkButtonDidTap(_ sender: UIButton) {
        guard sender.configuration?.title == Constant.defaultTitle else { return }
        
        copyLinkClosure?()
        
        showCopyLinkCompletedState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.resetCopyLinkButton()
        }
    }
}

// MARK: - Computed Property

private extension CommunityInviteCell {
    var communityImageView: UIImageView { baseView.communityImageView }
    var titleLabel: UILabel { baseView.titleLabel }
    var copyLinkButton: UIButton { baseView.primaryButton }
}

// MARK: - Constant

private extension CommunityInviteCell {
    enum Constant {
        static let defaultTitle = "팬 더 데려오기"
        static let copyLinkCompletedTitle = "링크 복사 완료"
    }
}
