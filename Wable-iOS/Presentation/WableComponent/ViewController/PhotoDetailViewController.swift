//
//  PhotoDetailViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/13/25.
//

import UIKit
import Photos

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

private extension PhotoDetailViewController {
    
    // MARK: - Setup Method
    
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
            self?.saveImage()
        }
        saveButton.addAction(saveAction, for: .touchUpInside)
    }
    
    // MARK: - Photo Method
    
    func saveImage() {
        Task {
            do {
                guard try await requestPhotoPermissionIfNeeded() else { return }
                try await saveImageToPhotoLibrary(image)
            } catch {
                WableLogger.log("\(error)", for: .error)
            }
        }
    }
    
    func requestPhotoPermissionIfNeeded() async throws -> Bool {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        if isPermissionGranted(currentStatus) {
            return true
        }
        
        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return isPermissionGranted(newStatus)
    }
    
    func isPermissionGranted(_ status: PHAuthorizationStatus) -> Bool {
        return status == .authorized || status == .limited
    }
    
    func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
    // MARK: - Computed Property
    
    var optimalImageViewSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        let imageSize = image.size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        var finalWidth: CGFloat
        var finalHeight: CGFloat
        
        if imageSize.width > screenSize.width {
            finalWidth = screenSize.width
            finalHeight = finalWidth / aspectRatio
        } else {
            finalWidth = imageSize.width
            finalHeight = imageSize.height
        }
        
        if finalHeight > screenSize.height {
            finalHeight = screenSize.height
            finalWidth = finalHeight * aspectRatio
        }
        
        return CGSize(width: finalWidth, height: finalHeight)
    }
}
