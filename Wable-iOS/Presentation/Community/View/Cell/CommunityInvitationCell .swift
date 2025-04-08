//
//  CommunityInvitationCell .swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/8/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class CommunityInvitationCell: UICollectionViewCell {
    
    // MARK: - UIComponent

    private let baseView = CommunityCellBaseView()
    
    private let progressTitleLabel = UILabel().then {
        $0.attributedText = "진행도".pretendardString(with: .caption1)
    }
    
    private let progressImageView = UIImageView(image: .icFan)
    
    private let progressBar = UIProgressView(progressViewStyle: .bar).then {
        $0.trackTintColor = .red
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 8
    }
    
    // MARK: - Property
    
    var linkCopyClosure: (() -> Void)?
    
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
        
        imageView.image = nil
        linkCopyClosure = nil
    }
}

// MARK: - Setup Method

private extension CommunityInvitationCell {
    func setupView() {
        contentView.addSubviews(
            baseView,
            progressTitleLabel,
            progressImageView,
            progressBar
        )
    }
    
    func setupConstraint() {
        baseView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        
    }
    
    func setupAction() {
        linkCopyButton.addTarget(self, action: #selector(linkCopyButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension CommunityInvitationCell {
    @objc func linkCopyButtonDidTap() {
        linkCopyClosure?()
    }
}

// MARK: - Computed Property

private extension CommunityInvitationCell {
    var imageView: UIImageView { baseView.imageView }
    var nameLabel: UILabel { baseView.nameLabel }
    var linkCopyButton: UIButton { baseView.actionButton }
}

// MARK: - Constant

private extension CommunityInvitationCell {
    enum Constant {
        static let defaultTitle = "팬 더 데려오기"
        static let linkCopyCompletedTitle = "링크 복사 완료"
    }
}
