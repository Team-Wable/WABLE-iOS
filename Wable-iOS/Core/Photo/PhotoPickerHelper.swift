//
//  PhotoPickerHelper.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import Combine
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
        showPhotoPicker()
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

// MARK: - Helper Method

extension PhotoPickerHelper {
    static func requestPhotoLibraryAccess() -> AnyPublisher<Bool, Never> {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            return Just(true).eraseToAnyPublisher()
        case .denied, .restricted:
            return Just(false).eraseToAnyPublisher()
        case .notDetermined:
            return Future<Bool, Never> { promise in
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                    promise(.success(newStatus == .authorized || newStatus == .limited))
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        @unknown default:
            return Just(false).eraseToAnyPublisher()
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

    static func saveImageToPhotoLibrary(_ image: UIImage) -> AnyPublisher<Void, Error> {
        Future { promise in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    static func saveImage(
        _ image: UIImage,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (Error) -> Void
    ) -> AnyCancellable {
        requestPhotoLibraryAccess()
            .flatMap { isAuthorized -> AnyPublisher<Void, Error> in
                guard isAuthorized else {
                    return Empty().eraseToAnyPublisher()
                }
                return saveImageToPhotoLibrary(image)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        onFailure(error)
                    }
                },
                receiveValue: { _ in
                    onSuccess()
                }
            )
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
