//
//  NotificationTableViewCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/21/24.
//

import UIKit

import SnapKit
import Kingfisher

final class NotificationTableViewCell: UITableViewCell {
    private let notiImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgProfileSmall
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22.adjusted
        return imageView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .gray600
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [contentLabel, timeLabel])
        stackView.axis = .vertical
        stackView.spacing = 4.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - Property

    var imageViewDidTapAction: (() -> Void)?
    
    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupConstraints()
        setupAction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        notiImageView.image = nil
    }
}

extension NotificationTableViewCell {
    func bindForActivity(data: ActivityNotificationDTO) {
        setProfileImage(for: data.triggerMemberProfileURL)
        setContentLabel(for: data)
        timeLabel.text = data.time
    }
    
    func bindForInformation(data: InfoNotificationDTO) {
        notiImageView.kfSetImage(url: data.imageURL)
        contentLabel.text = NotiInfoText(rawValue: data.infoNotificationType)?.text
        timeLabel.text = data.time
    }
}

// MARK: - Private Method

private extension NotificationTableViewCell {
    func setupView() {
        backgroundColor = .wableWhite
        
        contentView.addSubviews(notiImageView, labelStackView)
    }
    
    func setupConstraints() {
        notiImageView.snp.makeConstraints {
            $0.height.width.equalTo(44.adjusted)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        contentLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        labelStackView.snp.makeConstraints {
            $0.leading.equalTo(notiImageView.snp.trailing).offset(10.adjusted)
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        notiImageView.addGestureRecognizer(tapGesture)
        notiImageView.isUserInteractionEnabled = true
    }
    
    func setProfileImage(for urlString: String) {
        guard !urlString.isEmpty else {
            notiImageView.image = ImageLiterals.Image.imgProfile3
            return
        }
        
        if let profileImage = UserProfile(rawValue: urlString)?.image {
            notiImageView.image = profileImage
        } else {
            notiImageView.kf.indicatorType = .activity
            notiImageView.kf.setImage(
                with: URL(string: urlString),
                options: [.transition(.fade(1.0))]
            )
        }
    }
    
    func setContentLabel(for data: ActivityNotificationDTO) {
        let baseText = NotiActivityText(rawValue: data.notificationTriggerType)?.text(
            trigger: data.triggerMemberNickname,
            user: data.memberNickname
        ) ?? ""
        
        guard !data.notificationText.isEmpty else {
            contentLabel.text = baseText
            return
        }
        
        let truncatedText = data.notificationText.truncated(to: 15)
        contentLabel.text = "\(baseText)\n : \(truncatedText)"
    }
    
    @objc
    func imageViewDidTap() {
        imageViewDidTapAction?()
    }
}

extension UIImageView{
    
    // TODO: 추후 삭제 또는 별도의 파일 선언
    
    func kfSetImage(url: String?){
        guard let url = url else { return }
        
        if let url = URL(string: url) {
            kf.indicatorType = .activity
            kf.setImage(with: url,
                        placeholder: nil,
                        options: [.transition(.fade(1.0))], progressBlock: nil)
        }
    }
}
