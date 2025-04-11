//
//  ViewitContentView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//

import UIKit

import SnapKit
import Then

final class ViewitContentView: UIView {
    
    // MARK: - UIComponent

    private let viewitTextLabel = UILabel().then {
        $0.attributedText = "뷰잇 멘트는 최대 50자만 가능해요.".pretendardString(with: .body4)
        $0.textColor = UIColor("4a4a4a")
        $0.numberOfLines = 2
    }
    
    private let viewitCardButton = ViewitCardButton()
    
    private let likeButton = LikeButton()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        viewitText: String,
        videoThumbnailImageURL: URL?,
        videoTitle: String,
        siteName: String,
        isLiked: Bool,
        likeCount: Int
    ) {
        viewitTextLabel.text = viewitText
        
        viewitCardButton.configure(
            imageURL: videoThumbnailImageURL,
            videoTitle: videoTitle,
            siteName: siteName
        )
        
        likeButton.configureButton(isLiked: isLiked, likeCount: likeCount, postType: .content)
    }
}

// MARK: - Setup Method

private extension ViewitContentView {
    func setupView() {
        let viewitTextBackgroundView = UIView(backgroundColor: .purple10).then {
            $0.layer.cornerRadius = 8
        }
        viewitTextBackgroundView.addSubview(viewitTextLabel)
        
        let stackView = UIStackView(axis: .vertical).then {
            $0.spacing = 8
            $0.alignment = .fill
            $0.distribution = .fill
        }
        stackView.addArrangedSubviews(
            viewitTextBackgroundView,
            viewitCardButton
        )
        
        addSubviews(
            stackView,
            likeButton
        )
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        viewitTextLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        likeButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(viewitCardButton).inset(8)
        }
    }
}
