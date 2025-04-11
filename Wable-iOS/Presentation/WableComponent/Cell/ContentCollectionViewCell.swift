//
//  ContentCollectionViewCell.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

/// 게시물을 표시하기 위한 컬렉션 뷰 셀.
/// 사용자 정보, 제목, 내용, 이미지, 좋아요/댓글/내리기 버튼 등을 포함합니다.
///
/// 사용 예시:
/// ```swift
/// collectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.reuseIdentifier)
///
/// // cellForItemAt에서:
/// let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.reuseIdentifier, for: indexPath) as! ContentCollectionViewCell
/// cell.configureCell(info: contentInfo, postType: .others)
/// return cell
/// ```
final class ContentCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Enum
    
    enum CellType {
        case list
        case detail
    }
    
    // MARK: - Property
    // TODO: 셀 타입 따라 이미지 크기 설정하는 분기 처리 필요
    
    private var cellType: CellType = .list
    var likeButtonTapHandler: (() -> Void)?
    
    // MARK: - UIComponent
    
    private let infoView: PostUserInfoView = PostUserInfoView()
    
    private let contentStackView: UIStackView = UIStackView(axis: .vertical).then {
        $0.spacing = 10
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let titleLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
        $0.numberOfLines = 0
    }
    
    private let contentImageView: UIImageView = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.roundCorners([.all], radius: 8)
    }
    
    private let contentTextView: UITextView = UITextView().then {
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
        $0.dataDetectorTypes = [.link]
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.setPretendard(with: .body4)
        $0.textColor = .gray800
    }
    
    private lazy var ghostButton: GhostButton = GhostButton()
    
    lazy var likeButton: LikeButton = LikeButton()
    
    lazy var commentButton: CommentButton = CommentButton(type: .content)
    
    private let divideView: UIView = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentImageView.kf.cancelDownloadTask()
        contentImageView.image = nil
        contentTextView.text = nil
        titleLabel.text = nil
    }
}

// MARK: - Private Extension

private extension ContentCollectionViewCell {
    
    // MARK: - Setup

    func setupView() {
        contentStackView.addArrangedSubviews(
            titleLabel,
            contentImageView,
            contentTextView
        )
        
        contentView.addSubviews(
            infoView,
            contentStackView,
            ghostButton,
            likeButton,
            commentButton,
            divideView
        )
    }
    
    func setupConstraint() {
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.horizontalEdges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        contentImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.adjustedHeightEqualTo(192)
        }
        
        ghostButton.snp.makeConstraints {
            $0.top.equalTo(contentStackView.snp.bottom).offset(20)
            $0.leading.equalTo(infoView).offset(16)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        likeButton.snp.makeConstraints {
            $0.centerY.equalTo(ghostButton)
            $0.trailing.equalTo(commentButton.snp.leading).offset(-16)
        }
        
        commentButton.snp.makeConstraints {
            $0.centerY.equalTo(ghostButton)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        divideView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.adjustedHeightEqualTo(1)
        }
    }
    
    func setupAction() {
        ghostButton.addTarget(self, action: #selector(ghostButtonDidTap), for: .touchUpInside)
        infoView.settingButton.addTarget(self, action: #selector(settingButtonDidTap), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonDidTap), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        contentImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(contentImageViewDidTap)
            )
        )
        infoView.profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(profileImageViewDidTap)
            )
        )
    }
    
    // MARK: - @objc Method
    
    @objc func contentImageViewDidTap() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController,
              let image = contentImageView.image
        else {
            return
        }
        
        rootViewController.present(PhotoDetailViewController(image: image), animated: true)
    }
    
    @objc func profileImageViewDidTap() {
        // TODO: 프로필 이동 로직 구현 필요
        
        WableLogger.log("profileImageViewDidTap", for: .debug)
    }
    
    @objc func settingButtonDidTap() {
        // TODO: 바텀시트 올라오는 로직 구현 필요
        
        WableLogger.log("settingButtonDidTap", for: .debug)
    }
    
    @objc func ghostButtonDidTap() {
        // TODO: 내리기 로직 구현 필요
        
        WableLogger.log("ghostButtonDidTap", for: .debug)
    }
    
    @objc func commentButtonDidTap() {
        // TODO: 상세 화면으로 이동 로직 구현 필요
        
        WableLogger.log("commentButtonDidTap", for: .debug)
    }
    
    @objc func likeButtonDidTap() {
        let newCount = likeButton.isLiked ? likeButton.likeCount - 1 : likeButton.likeCount + 1
        
        likeButton.configureButton(isLiked: !likeButton.isLiked, likeCount: newCount, postType: .content)
        
        self.likeButtonTapHandler?()
    }
}

// MARK: - Helper Method

private extension ContentCollectionViewCell {
    /// 셀의 투명도 설정
    /// - Parameter opacity: 투명도 값 (0.0 ~ 1.0)
    func ghostCell(opacity: Float) {
        [
            infoView,
            contentImageView,
            titleLabel,
            contentTextView
        ].forEach {
            $0.alpha = CGFloat(opacity)
        }
    }
}

// MARK: - Configure Extension

extension ContentCollectionViewCell {
    /// 게시물 셀 구성 메서드
    /// - Parameters:
    ///   - info: 게시물 정보
    ///   - postType: 게시물 타입 (.mine 또는 .others)
    ///   - cellType: 셀 타입 (홈 화면 셀 또는 상세 화면 셀)
    ///   - likeButtonTapHandler: 좋아요 버튼을 클릭했을 때 실행될 로직
    func configureCell(info: ContentInfo, postType: AuthorType, cellType: CellType = .list, likeButtonTapHandler: (() -> Void)?) {
        self.cellType = cellType
        self.likeButtonTapHandler = likeButtonTapHandler
        
        guard let createdDate = info.createdDate else { return }
        
        infoView.configureView(
            userProfileURL: info.author.profileURL,
            userName: info.author.nickname,
            userFanTeam: info.author.fanTeam,
            opacity: info.opacity.displayedValue,
            createdDate: createdDate,
            postType: .content
        )
        
        contentStackView.spacing = info.imageURL == nil ? 4 : 10
    
        titleLabel.attributedText = info.title.pretendardString(with: .head2)
        contentImageView.isHidden = info.imageURL == nil
        contentImageView.kf.setImage(with: info.imageURL)
        
        contentTextView.text = info.text
        contentTextView.isUserInteractionEnabled = cellType == .detail
        
        ghostButton.configureButton(type: .large, status: .normal)
        likeButton.configureButton(isLiked: info.like.status, likeCount: info.like.count, postType: .content)
        commentButton.configureButton(commentCount: info.commentCount)
        
        switch postType {
        case .mine:
            ghostButton.isHidden = true
        case .others:
            break
        }
        
        switch info.status {
        case .normal:
            ghostCell(opacity: info.opacity.alpha)
        case .ghost:
            ghostCell(opacity: 0.15)
            ghostButton.configureButton(type: .large, status: .disabled)
        case .blind:
            DispatchQueue.main.async {
                self.contentImageView.image = .imgFeedIsBlind
            }
            
            titleLabel.isHidden = true
            contentTextView.isHidden = true
            contentImageView.snp.updateConstraints {
                $0.adjustedHeightEqualTo(98)
            }
            ghostCell(opacity: info.opacity.alpha)
        }
    }
}
