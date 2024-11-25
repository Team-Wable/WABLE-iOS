//
//  InfoDetailView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit

import SnapKit

final class InfoDetailView: UIView {
    private let statusBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableBlack
        return view
    }()
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .wableBlack
        label.font = .head1
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray500
        label.font = .caption2
        label.textAlignment = .right
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.adjusted
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.numberOfLines = 0
        label.textColor = .gray800
        return label
    }()
    
    private let bodyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension InfoDetailView {
    func setupView() {
        backgroundColor = .wableWhite
        
        scrollView.addSubview(contentView)
        
        [imageView, bodyLabel].forEach { bodyStackView.addArrangedSubview($0) }
        
        contentView.addSubviews(titleLabel, timeLabel, bodyStackView, bottomBorder)
        
        addSubviews(statusBarBackgroundView, scrollView)
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide

        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(192.adjustedH)
        }
        
        bodyStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        bottomBorder.snp.makeConstraints { make in
            make.top.equalTo(bodyStackView.snp.bottom).offset(18)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(8)
        }
    }
}
