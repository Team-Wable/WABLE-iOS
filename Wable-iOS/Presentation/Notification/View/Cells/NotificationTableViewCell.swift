//
//  NotificationTableViewCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/21/24.
//

import UIKit

import SnapKit

final class NotificationTableViewCell: UITableViewCell{
    
    // MARK: - Properties
    
    static let identifier = "NotificationTableViewCell"
    
    // MARK: - Components
    
    private let notiImageView = UIImageView()
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.text = "이제 곧 경기가 시작해요! 얼른 치킨 시키고 같이\n경기 보러 가볼까요?"
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.text = "23분전"
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

    func bindForActivity(data: InfoNotificationDTO) {
        // TODO: - imageURL KingFisher로 변환
        notiImageView.image = ImageLiterals.Image.imgProfileSmall
        contentLabel.text = data.infoNotificationType
    }
    
    func bindForInformation(data: ActivityNotificationDTO) {
        // TODO: - imageURL KingFisher로 변환
        notiImageView.image = ImageLiterals.Image.imgProfileSmall
        contentLabel.text = data.notificationText
        timeLabel.text = "23분전"
    }
}
