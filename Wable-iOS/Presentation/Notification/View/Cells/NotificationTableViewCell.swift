//
//  NotificationTableViewCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/21/24.
//

import UIKit

import SnapKit
import Kingfisher

final class NotificationTableViewCell: UITableViewCell{
    
    // MARK: - Properties
    
    static let identifier = "NotificationTableViewCell"
    
    // MARK: - Components
    
    private let notiImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22.adjusted
        return imageView
    }()
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .gray600
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [contentLabel,
                                                       timeLabel])
        stackView.axis = .vertical
        stackView.spacing = 4.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .wableWhite
        setHierarchy()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions

    private func setHierarchy() {
        self.contentView.addSubviews(notiImageView,
                                     labelStackView)

    }
    
    private func setLayout() {
        notiImageView.image = ImageLiterals.Image.imgProfileSmall

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
    
    func bindForActivity(data: ActivityNotificationDTO) {
        // TODO: - imageURL KingFisher로 변환
        notiImageView.kfSetImage(url: data.triggerMemberProfileURL)
        contentLabel.text = NotiActivityText(rawValue: data.notificationTriggerType)?.text(from: data.triggerMemberNickname,
                                                                                           to: data.memberNickname)
        if data.notificationText != "" {
            let text = (NotiActivityText(rawValue: data.notificationTriggerType)?.text(from: data.triggerMemberNickname,
                                                                                       to: data.memberNickname) ?? "") + "\n :\(data.notificationText.truncated(to: 15))"
            contentLabel.text = text
        }
        timeLabel.text = data.time
    }
    
    func bindForInformation(data: InfoNotificationDTO) {
        notiImageView.kfSetImage(url: data.imageURL)
        contentLabel.text = NotiInfoText(rawValue: data.infoNotificationType)?.text
        timeLabel.text = data.time
    }
}

extension UIImageView{
    func kfSetImage(url : String?){
        
        guard let url = url else { return }
        
        if let url = URL(string: url) {
            kf.indicatorType = .activity
            kf.setImage(with: url,
                        placeholder: nil,
                        options: [.transition(.fade(1.0))], progressBlock: nil)
        }
    }
}
