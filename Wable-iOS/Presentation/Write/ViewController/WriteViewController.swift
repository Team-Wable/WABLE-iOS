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
    
    static let writeCompletedNotification = Notification.Name("WriteCompletedNotification")
    
    private var cancelBag = CancelBag()
    private let viewModel: WriteViewModel
    private var transparency: Int = 0
    var writeViewDidDisappear: (() -> Void)?
    
    private lazy var postButtonTapped = self.rootView.writeTextView.postButton.publisher(for: .touchUpInside)
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .map { _ in
        return WriteContentImageRequestDTO(
            contentTitle: self.rootView.writeTextView.titleTextField.text ?? "",
            contentText: self.rootView.writeTextView.contentTextView.text,
            photoImage: self.rootView.writeTextView.photoImageView.image)
    }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private let rootView = WriteView()
    private let topDivisionLine = UIView().makeDivisionLine()
    
    private var writeCanclePopupView: WablePopupView? = nil
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
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        self.title = "프로필 편집"
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        navigationItem.leftBarButtonItem = backButton
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
        writeViewDidDisappear?()
    }
}

// MARK: - Extensions

extension WriteViewController {
    private func setUI() {
        self.title = "새로운 글"
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    private func setHierarchy() {
        self.view.addSubviews(topDivisionLine)
    }
    
    private func setLayout() {
        topDivisionLine.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
        }
    }
    
    private func setDelegate() {
        
    }
    
    private func setAddTarget() {
        self.rootView.writeTextView.photoButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        let input = WriteViewModel.Input(postButtonTapped: postButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    DispatchQueue.main.async {
                        self.WriteCompleted()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .store(in: self.cancelBag)
    }
    
    private func WriteCompleted() {
        NotificationCenter.default.post(name: WriteViewController.writeCompletedNotification, object: nil, userInfo: ["showToast": true])
    }
    
    @objc
    private func backButtonDidTapped() {
        if self.rootView.writeTextView.titleTextField.text != "" || self.rootView.writeTextView.contentTextView.text != "" {
            
            self.writeCanclePopupView = WablePopupView(popupTitle: StringLiterals.Write.writeCanclePopupTitleLabel,
                                                  popupContent: "",
                                                  leftButtonTitle: StringLiterals.Write.writeCanclePopupLeftButtonTitle,
                                                  rightButtonTitle: StringLiterals.Write.writeCanclePopupRightButtonTitle)
            
            if let popupView = self.writeCanclePopupView {
                if let window = UIApplication.shared.keyWindowInConnectedScenes {
                    window.addSubviews(popupView)
                }
                
                popupView.delegate = self
                
                popupView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            }
            
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
//        navigationController?.popViewController(animated: true)
    }
    
    @objc private func photoButtonTapped() {
        AmplitudeManager.shared.trackEvent(tag: "click_attach_photo")
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

extension WriteViewController: WablePopupDelegate {
    func cancleButtonTapped() {
        self.writeCanclePopupView?.removeFromSuperview()
    }
    
    func confirmButtonTapped() {
        self.writeCanclePopupView?.removeFromSuperview()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func singleButtonTapped() {
        
    }
}
