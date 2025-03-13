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
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    private let dismissButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .btnRemovePhoto
        $0.configuration = configuration
    }
    
    // MARK: - Property
    
    private let image: UIImage
    
    // MARK: - Initializer
    
    init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
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

// MARK: - Setup Method

private extension PhotoDetailViewController {
    func setupView() {        
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        
        view.addSubviews(
            imageView,
            dismissButton
        )
        
        imageView.image = image
    }
    
    func setupConstraint() {
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(optimalImageViewHeight)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.adjustedWidthEqualTo(60)
            make.height.equalTo(dismissButton.snp.width)
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
