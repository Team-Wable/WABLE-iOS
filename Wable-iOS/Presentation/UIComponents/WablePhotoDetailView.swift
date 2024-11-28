//
//  WablePhotoDetailView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 9/15/24.
//

import UIKit

import SnapKit

final class WablePhotoDetailView: UIView {
    
    // MARK: - Properties
    
    var imageHeightConstraint: Constraint?
    private let maxHeight: CGFloat = UIScreen.main.bounds.height
    
    // MARK: - UI Components
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableBlack.withAlphaComponent(0.6)
        return view
    }()
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let removePhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnRemovePhoto, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Extensions

extension WablePhotoDetailView {
    
    private func setHierarchy() {
        self.addSubview(dimView)
        dimView.addSubviews(photoImageView,
                            removePhotoButton)
    }
    
    private func setLayout() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        photoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
            imageHeightConstraint = $0.height.equalTo(0).constraint // 처음엔 높이 0으로 설정
        }
        
        removePhotoButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.bottom.equalToSuperview().inset(101)
            $0.centerX.equalToSuperview()
        }
    }
    
    func updateImageViewHeight(with image: UIImage) {
        // 이미지 비율 계산
        let aspectRatio = image.size.height / image.size.width
        
        // 이미지의 너비를 기준으로 높이 계산
        let imageViewWidth = UIScreen.main.bounds.width
        var newHeight = imageViewWidth * aspectRatio
        
        // 높이가 설정한 최대 높이보다 크면 최대 높이로 설정
        if newHeight > maxHeight {
            newHeight = maxHeight
        }
        
        // 이미지 뷰의 높이 제약을 업데이트
        imageHeightConstraint?.update(offset: newHeight)
        
        // 레이아웃 업데이트
        self.layoutIfNeeded()
    }
}
