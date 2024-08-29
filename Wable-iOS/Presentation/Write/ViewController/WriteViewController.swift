//
//  WriteViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit
import Photos
import PhotosUI

import SnapKit

final class WriteViewController: UIViewController {
    
    // MARK: - Properties
    
    static let showWriteToastNotification = Notification.Name("ShowWriteToastNotification")
    
    private var cancelBag = CancelBag()
    private let viewModel: WriteViewModel
    private var transparency: Int = 0
    
    private lazy var backButtonTapped = self.navigationBackButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var postButtonTapped = self.rootView.writeTextView.postButton.publisher(for: .touchUpInside).map { _ in
        return WriteContentImageRequestDTO(
            contentTitle: self.rootView.writeTextView.titleTextField.text ?? "",
            contentText: self.rootView.writeTextView.contentTextView.text,
            photoImage: self.rootView.writeTextView.photoImageView.image)
    }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private let rootView = WriteView()
//    private let banView = WriteBanView()
    
    // MARK: - Life Cycles
    
    init(viewModel: WriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        setAddTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
        
        setUI()
        setHierarchy()
        setLayout()
        getAPI()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)

    }
}

// MARK: - Extensions

extension WriteViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    private func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton)
    }
    
    private func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
    }
    
    private func setDelegate() {
//        self.rootView.writeCanclePopupView.delegate = self
    }
    
    private func setAddTarget() {
        self.rootView.writeTextView.photoButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        let input = WriteViewModel.Input(backButtonTapped: backButtonTapped,
                                         postButtonTapped: postButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.WriteCompleted()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: self.cancelBag)
    }
    
    private func WriteCompleted() {
        NotificationCenter.default.post(name: WriteViewController.showWriteToastNotification, object: nil, userInfo: ["showToast": true])
    }
    
    @objc private func photoButtonTapped() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            presentPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.presentPicker()
                    }
                }
            }
        case .denied, .restricted:
            authSettingOpen()
        default:
            break
        }
    }
    
    private func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // 이미지만 필터링
        configuration.selectionLimit = 1 // 선택 제한
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func authSettingOpen() {
        let message = StringLiterals.Camera.photoNoAuth
        
        let alert = UIAlertController(title: "설정", message: message, preferredStyle: .alert)
        
        let cancle = UIAlertAction(title: "닫기", style: .default)
        
        let confirm = UIAlertAction(title: "권한설정하기", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        alert.addAction(cancle)
        alert.addAction(confirm)
        
        self.present(alert, animated: true, completion: nil)
    }
    
//    @objc
//    private func cancleNavigationBarButtonTapped() {
//        if self.rootView.writeTextView.contentTextView.text == "" && self.rootView.writeTextView.linkTextView.text == "" && self.rootView.writeTextView.photoImageView.image == nil {
//            popupNavigation()
//        } else {
//            self.rootView.writeCanclePopupView.alpha = 1
//        }
//    }
//    
//    @objc
//    private func promiseButtonTapped() {
//        self.banView.removeFromSuperview()
//        self.navigationController?.popViewController(animated: true)
//    }
}

// MARK: - Network

extension WriteViewController {
    private func getAPI() {
//        if UserDefaults.standard.integer(forKey: "memberGhost") <= -85 {
//            self.banView.snp.makeConstraints {
//                $0.edges.equalToSuperview()
//            }
//        } else {
//            self.banView.removeFromSuperview()
//        }
    }
}

//extension WriteViewController: DontBePopupDelegate {
//    func cancleButtonTapped() {
//        self.rootView.writeCanclePopupView.alpha = 0
//    }
//    
//    func confirmButtonTapped() {
//        self.rootView.writeCanclePopupView.alpha = 0
//        popupNavigation()
//    }
//}

extension WriteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let selectedImage = results.first else { return }
        
        selectedImage.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self.rootView.writeTextView.photoImageView.isHidden = false
                    self.rootView.writeTextView.photoImageView.image = image
                    
                    self.rootView.writeTextView.contentTextView.snp.remakeConstraints {
                        $0.top.equalTo(self.rootView.writeTextView.photoImageView.snp.bottom).offset(12.adjusted)
                        $0.leading.trailing.equalToSuperview().inset(24.adjusted)
                        $0.bottom.equalTo(self.rootView.writeTextView.keyboardToolbarView.snp.top)
                    }
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
}
