//
//  PermissionManager.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//

import Photos
import UIKit

final class PermissionManager {
    static let shared = PermissionManager()

    private init() {}
}

// MARK: - Helper Method

extension PermissionManager {
    func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
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

    func requestPhotoLibraryAccess() async -> Bool {
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

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func showSettingsAlert(
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
        alert.addAction(UIAlertAction(title: "권한 설정하기", style: .default) { [weak self] _ in
            self?.openSettings()
        })

        viewController.present(alert, animated: true)
    }
}

