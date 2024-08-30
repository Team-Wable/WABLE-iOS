//
//  RankingView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/29/24.
//

import UIKit

import SnapKit

final class RankingView: UIView {

    // MARK: - Properties
    
    // MARK: - UI Components
    
    private var sessionView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .purple10
        view.layer.cornerRadius = 8.adjusted
        return view
    }()
    
    private var sessionLabel: UILabel = {
       let label = UILabel()
        label.text = StringLiterals.Info.lckSummer
        label.font = .body3
        label.textColor = .purple100
        return label
    }()
    
    private var rankingImageView: UIImageView = {
        let imageView = UIImageView(image: ImageLiterals.Image.imgRanking)
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray400
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
        setRegisterCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension RankingView {
    private func setUI() {
        self.backgroundColor = .white
    }
    
    private func setHierarchy() {
        self.addSubviews(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(sessionView,
                                rankingImageView)
        sessionView.addSubview(sessionLabel)
    }
    
    private func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview() // ScrollView의 폭에 맞춤
        }
        
        sessionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18.adjusted)
            $0.height.equalTo(39.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
        }
        
        sessionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        rankingImageView.snp.makeConstraints {
            $0.width.equalTo(343.adjusted)
            $0.height.equalTo(434.adjusted)
            $0.top.equalTo(sessionView.snp.bottom).offset(10.adjusted)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setAddTarget() {

    }
    
    private func setRegisterCell() {

    }
    
    private func setDataBind() {
        
    }
}
