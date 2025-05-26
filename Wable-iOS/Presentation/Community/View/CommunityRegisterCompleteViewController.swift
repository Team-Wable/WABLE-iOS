//
//  CommunityRegisterCompleteViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/11/25.
//

import UIKit

import SnapKit
import Then

final class CommunityRegisterCompleteViewController: UIViewController {
    
    // MARK: - Property

    private let teamName: String
    
    // MARK: - Initializer

    init(teamName: String) {
        self.teamName = teamName
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
}

// MARK: - Setup Method

private extension CommunityRegisterCompleteViewController {
    func setupView() {
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        
        let backgroundView = UIView(backgroundColor: .wableWhite).then {
            $0.layer.cornerRadius = 16
        }
        
        let imageView = UIImageView(image: .icCircleCheck)
        
        let titleLabel = UILabel().then {
            $0.attributedText = StringLiterals.Community.completeSheetTitle.pretendardString(with: .head1)
            $0.textAlignment = .center
        }
        
        let descriptionLabel = UILabel().then {
            $0.attributedText = """
                                \(teamName)팀을 응원하는 팬분들이 더 모여야
                                \(teamName) 라운지가 오픈돼요!
                                팬 더 데려오기를 통해 링크를 복사하여
                                함께 응원할 팬을 데려와주세요!
                                """.pretendardString(with: .body2)
            $0.textColor = .gray700
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        backgroundView.addSubviews(
            imageView,
            titleLabel,
            descriptionLabel
        )
        
        view.addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(32)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.adjustedWidthEqualTo(72)
            make.adjustedHeightEqualTo(72)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-32)
        }
    }
}
