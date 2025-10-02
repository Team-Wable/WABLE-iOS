//
//  PhotoDetailViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/13/25.
//

import UIKit
import Photos
import Combine

import SnapKit
import Then

final class PhotoDetailViewController: UIViewController {
    
    // MARK: - UIComponent
    
    private let backButton = UIButton().then {
        $0.setImage(.icBackCircle, for: .normal)
    }
    
    private let saveButton = UIButton().then {
        $0.setImage(.icDownloadCircle, for: .normal)
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    
    // MARK: - Property

    private let image: UIImage
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer
    
    init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    @available(*, unavailable)
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
        view.backgroundColor = .wableBlack
        
        view.addSubviews(
            imageView,
            backButton,
            saveButton
        )
        
        imageView.image = image
    }
    
    func setupConstraint() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(4)
            make.leading.equalTo(safeArea).offset(12)
            make.size.equalTo(48)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.size.equalTo(backButton)
            make.trailing.equalTo(safeArea).offset(-12)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.height.lessThanOrEqualToSuperview()
            make.size.equalTo(optimalImageViewSize)
        }
    }
    
    func setupAction() {
        let popAction = UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        backButton.addAction(popAction, for: .touchUpInside)
        
        let saveAction = UIAction { [weak self] _ in
            AmplitudeManager.shared.trackEvent(tag: .clickDownloadPhoto)
            self?.saveImage()
        }
        saveButton.addAction(saveAction, for: .touchUpInside)
    }
}

// MARK: - Helper Method

private extension PhotoDetailViewController {
    func saveImage() {
        PhotoPickerHelper.saveImage(
            image,
            onSuccess: {
                ToastView(status: .complete, message: StringLiterals.PhotoDetail.successMessage).show()
            },
            onFailure: { error in
                ToastView(status: .error, message: StringLiterals.PhotoDetail.errorMessage).show()
                WableLogger.log("\(error)", for: .error)
            }
        )
        .store(in: cancelBag)
    }
}

// MARK: - Computed Property

private extension PhotoDetailViewController {
    var optimalImageViewSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        let imageSize = image.size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        var finalWidth: CGFloat
        var finalHeight: CGFloat
        
        let condition = imageSize.width > screenSize.width
        finalWidth = condition ? screenSize.width : imageSize.width
        finalHeight = condition ? finalWidth / aspectRatio : imageSize.height
        
        if finalHeight > screenSize.height {
            finalHeight = screenSize.height
            finalWidth = finalHeight * aspectRatio
        }
        
        return CGSize(width: finalWidth, height: finalHeight)
    }
}
