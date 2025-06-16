//
//  PhotoDetailViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/13/25.
//

import UIKit

import SnapKit
import Then

final class PhotoDetailViewController: UIViewController {
    
    // MARK: - UIComponent
    
    private let dismissButton = UIButton().then {
        $0.setImage(.icBackCircle, for: .normal)
    }
    
    private let downloadButton = UIButton().then {
        $0.setImage(.icDownloadCircle, for: .normal)
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    
    // MARK: - Property
    
    private let image: UIImage
    
    // MARK: - Initializer
    
    init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
}

private extension PhotoDetailViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        view.backgroundColor = .wableBlack
        
        view.addSubviews(
            dismissButton,
            downloadButton,
            imageView
        )
        
        imageView.image = image
    }
    
    func setupConstraint() {
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(4)
            make.leading.equalTo(safeArea).offset(12)
            make.size.equalTo(48)
        }
        
        downloadButton.snp.makeConstraints { make in
            make.top.size.equalTo(dismissButton)
            make.trailing.equalTo(safeArea).offset(-12)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.height.lessThanOrEqualToSuperview()
            make.height.equalTo(optimalImageViewHeight)
        }
    }
    
    func setupAction() {
        let dismissAction = UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        dismissButton.addAction(dismissAction, for: .touchUpInside)
    }
}

// MARK: - Computed Property

private extension PhotoDetailViewController {
    var optimalImageViewHeight: CGFloat {
        let aspectRatio = image.size.height / image.size.width
        let screenWidth = UIScreen.main.bounds.width
        let height = screenWidth * aspectRatio
        
        let maxHeight: CGFloat = 812.adjustedHeight
        
        return min(height, maxHeight)
    }
}
