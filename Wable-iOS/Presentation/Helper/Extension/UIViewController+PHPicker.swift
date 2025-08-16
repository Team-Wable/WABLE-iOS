//
//  UIViewController+PHPicker.swift
//  Wable-iOS
//
//  Created by YOUJIM on 8/15/25.
//


import UIKit
import Photos
import PhotosUI

extension UIViewController {
    func setPhotoPermission(delegate: PHPickerViewControllerDelegate) {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .denied, .restricted:
            presentSettings()
        case .authorized, .limited:
            presentPhotoPicker(delegate: delegate)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    if status == .authorized { self.presentPhotoPicker(delegate: delegate) }
                }
            }
        default:
            break
        }
    }
    
    func presentPhotoPicker(delegate: PHPickerViewControllerDelegate) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = delegate
        
        present(picker, animated: true)
    }
    
    func presentSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        let message = StringLiterals.Empty.photoPermission
        let alert = UIAlertController(title: "설정", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        alert.addAction(UIAlertAction(title: "권한 설정하기", style: .default) { _ in UIApplication.shared.open(url) })
        
        present(alert, animated: true, completion: nil)
    }
}
