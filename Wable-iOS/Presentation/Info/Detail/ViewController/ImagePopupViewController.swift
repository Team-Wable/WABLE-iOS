//
//  ImagePopupViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/25/24.
//

import UIKit

import SnapKit

final class ImagePopupViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnRemovePhoto, for: .normal)
        return button
    }()
    
    private let image: UIImage
    
    // MARK: - Initializer
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        setupAction()
    }
}

private extension ImagePopupViewController {
    func setupView() {
        view.backgroundColor = .wableBlack.withAlphaComponent(0.7)
        
        imageView.image = image
        
        view.addSubviews(imageView, dismissButton)
        
        view.bringSubviewToFront(dismissButton)
    }
    
    func setupConstraints() {
        let aspectRatio = image.size.height / image.size.width
        
        var height = UIScreen.main.bounds.width * aspectRatio
        
        let maxHeight: CGFloat = 450
        
        if height > maxHeight {
            height = maxHeight
        }
        
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(height)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(imageView).inset(8)
            make.size.equalTo(44.adjusted)
        }
    }
    
    func setupAction() {
        let dismissAction = UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        dismissButton.addAction(dismissAction, for: .touchUpInside)
    }
}
