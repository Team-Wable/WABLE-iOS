//
//  PhotoPickerHelper.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import Photos
import PhotosUI
import UIKit

final class PhotoPickerHelper: NSObject {

    // MARK: - Property

    private var onImageSelected: ((UIImage) -> Void)?
    private weak var presentingViewController: UIViewController?

    // MARK: - Life Cycle

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
    }

    func presentPhotoPicker(onImageSelected: @escaping (UIImage) -> Void) {
        self.onImageSelected = onImageSelected

        PhotoPickerHelper.requestPhotoLibraryAccess { [weak self] isAuthorized in
            guard let self else { return }

            if isAuthorized {
                self.showPhotoPicker()
            } else {
                guard let viewController = self.presentingViewController else { return }
                PhotoPickerHelper.showSettingsAlert(
                    from: viewController,
                    message: StringLiterals.Empty.photoPermission
                )
            }
        }
    }
}

// MARK: - Private Method

private extension PhotoPickerHelper {
    func showPhotoPicker() {
        let picker = createPhotoPicker()
        presentingViewController?.present(picker, animated: true)
    }

    func createPhotoPicker() -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }

    func loadImage(from itemProvider: NSItemProvider) {
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let image = image as? UIImage else { return }

            DispatchQueue.main.async {
                self?.onImageSelected?(image)
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PhotoPickerHelper: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }
        loadImage(from: result.itemProvider)
    }
}

// MARK: - Helper Method

extension PhotoPickerHelper {
    static func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        @unknown default:
            completion(false)
        }
    }

    static func requestPhotoLibraryAccess() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return newStatus == .authorized || newStatus == .limited
        @unknown default:
            return false
        }
    }

    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    static func showSettingsAlert(
        from viewController: UIViewController,
        title: String = "설정",
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        alert.addAction(UIAlertAction(title: "권한 설정하기", style: .default) { _ in
            openSettings()
        })

        viewController.present(alert, animated: true)
    }
}
