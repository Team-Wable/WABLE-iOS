//
//  FeedDetailTableViewCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

import UIKit

import SnapKit

final class FeedDetailTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "FeedDetailTableViewCell"
    var menuButtonTapped: (() -> Void)?
    var profileButtonAction: (() -> Void) = {}
    var isMyContent: Bool = Bool()
    
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    
    // MARK: - Components
    
    let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableWhite
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let infoView = FeedInfoView()
    
    let bottomView = FeedDetailBottomView()
    
    let contentLabel: CopyableLabel = {
        let label = CopyableLabel()
        label.lineBreakMode = .byCharWrapping
        label.textColor = .gray800
        label.font = .body4
        label.numberOfLines = 0
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgProfileSmall
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 18.adjusted
        return imageView
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Icon.icMeatball, for: .normal)
        return button
    }()
    
    private let seperateLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    private let blindImageView: UIImageView = {
        let imageView = UIImageView(image: ImageLiterals.Image.imgRelplyIsBlind)
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .wableWhite
        setHierarchy()
        setLayout()
        setAddTarget()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.profileImageView.contentMode = .scaleAspectFill
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
            self.profileImageView.clipsToBounds = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage()
        self.contentLabel.attributedText = nil
        self.contentLabel.textColor = .gray800
    }

    // MARK: - Functions

    private func setHierarchy() {
        self.contentView.addSubviews(grayView,
                                     profileImageView,
                                     menuButton,
                                     infoView,
                                     contentLabel,
                                     blindImageView,
                                     bottomView,
                                     seperateLineView)
    }
    
    private func setLayout() {
        grayView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        profileImageView.snp.makeConstraints {
            $0.height.width.equalTo(30.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.centerY.equalTo(infoView)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18.adjusted)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8.adjusted)
            $0.height.equalTo(43.adjusted)
        }
        
        menuButton.snp.makeConstraints {
            $0.height.width.equalTo(32.adjusted)
            $0.top.equalTo(infoView)
            $0.trailing.equalToSuperview().inset(16.adjusted)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(12.adjusted)
            $0.leading.equalToSuperview().inset(52.adjusted)
            $0.trailing.equalTo(menuButton)
            $0.bottom.lessThanOrEqualTo(bottomView.snp.top).offset(-12.adjusted)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.equalTo(contentLabel)
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(31.adjusted)
            $0.bottom.equalToSuperview().inset(18.adjusted)
        }
        
        seperateLineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setAddTarget() {
        self.menuButton.addTarget(self, action: #selector(menuButtonDidTapped), for: .touchUpInside)
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped)))
    }
    
    @objc
    private func menuButtonDidTapped() {
        menuButtonTapped?()
    }
    
    @objc
    private func profileButtonTapped() {
        profileButtonAction()
    }
    
    @objc func handleContentLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = contentLabel.attributedText else { return }
        
        let location = gesture.location(in: contentLabel)
        let index = contentLabel.indexOfAttributedTextCharacterAtPoint(point: location)
        
        attributedText.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedText.length), options: []) { value, range, _ in
            if let url = value as? String, NSLocationInRange(index, range) {
                var urlString = url
                if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                    urlString = "https://\(urlString)"
                }
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // URL을 하이퍼링크로 바꾸는 함수
    private func attributedString(for text: String) -> NSAttributedString {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return NSAttributedString(string: text)
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: text) else { continue }
            let url = text[range]
            attributedString.addAttribute(.link, value: url, range: NSRange(range, in: text))
        }
        
        return attributedString
    }

    
    func bind(data: FlattenReplyModel) {
        profileImageView.load(url: data.memberProfileURL)
        
        infoView.bind(nickname: data.memberNickname,
                      team: Team(rawValue: data.memberFanTeam) ?? .TBD,
                      ghostPercent: data.memberGhost,
                      time: data.time)
        
        updateLayoutForReplyType(with: data.parentCommentID)

        if let profileImage = UserProfile(rawValue: data.memberProfileURL) {
            profileImageView.image = profileImage.image
        } else {
            profileImageView.kfSetImage(url: data.memberProfileURL)
        }
        bottomView.bind(heart: data.commentLikedNumber)
        
        bottomView.isLiked = data.isLiked
        
        if data.isGhost || data.isBlind ?? false {
            bottomView.ghostButton.setImage(ImageLiterals.Button.btnGhostDisabledSmall, for: .normal)
            bottomView.ghostButton.isEnabled = false
        } else {
            bottomView.ghostButton.setImage(ImageLiterals.Button.btnGhostDefaultSmall, for: .normal)
            bottomView.ghostButton.isEnabled = true
        }
        
        isReplyBlind(isBlind: data.isBlind ?? false)
        guard data.isBlind == false else { return }
        
        contentLabel.text = data.commentText

        contentLabel.attributedText = attributedString(for: data.commentText)
        
        contentLabel.snp.remakeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(12.adjusted)
            $0.leading.equalToSuperview().inset(52.adjusted)
            $0.trailing.equalTo(menuButton)
            $0.bottom.equalTo(bottomView.snp.top).offset(-10.adjusted)
        }

        let tapContentLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleContentLabelTap(_:)))
        contentLabel.isUserInteractionEnabled = true
        contentLabel.addGestureRecognizer(tapContentLabelGesture)
        
    }
    
    func isReplyBlind(isBlind: Bool) {
        contentLabel.isHidden = isBlind
        blindImageView.isHidden = !isBlind
        
        if isBlind {
            contentLabel.removeConstraints(contentLabel.constraints)
            blindImageView.snp.makeConstraints {
                $0.height.equalTo(50.adjustedH).priority(.high)
                $0.top.equalTo(infoView.snp.bottom).offset(12.adjusted)
                $0.leading.equalToSuperview().inset(54.adjusted).priority(.high)
                $0.trailing.equalTo(menuButton).priority(.high)
                $0.bottom.equalTo(bottomView.snp.top).offset(-10.adjusted)
            }
        } else {
            blindImageView.removeConstraints(blindImageView.constraints)
            contentLabel.snp.makeConstraints {
                $0.top.equalTo(infoView.snp.bottom).offset(12.adjusted)
                $0.leading.equalToSuperview().inset(52.adjusted)
                $0.trailing.equalTo(menuButton)
                $0.bottom.lessThanOrEqualTo(bottomView.snp.top).offset(-12.adjusted)
            }
        }
    }
    
    func hideChildReplyForMyPage() {
        bottomView.hideReplyButton()
    }
    
    func updateLayoutForReplyType(with parentCommentID: Int) {
        if parentCommentID == -1 {
            makeReplyLayout()
        } else {
            makeChildReplyLayout()
        }
        
        bottomView.setupReplyButtonVisibility(with: parentCommentID)
    }
    
    private func makeChildReplyLayout() {
        profileImageView.snp.remakeConstraints {
            $0.height.width.equalTo(30.adjusted)
            $0.leading.equalToSuperview().inset(52.adjusted)
            $0.centerY.equalTo(infoView)
        }
    }
    
    private func makeReplyLayout() {
        profileImageView.snp.remakeConstraints {
            $0.height.width.equalTo(30.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.centerY.equalTo(infoView)
        }
    }
}
