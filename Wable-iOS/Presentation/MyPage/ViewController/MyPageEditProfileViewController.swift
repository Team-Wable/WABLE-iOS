//
//  MyPageEditProfileViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/20/24.
//

import UIKit
import Photos
import PhotosUI

import SnapKit

final class MyPageEditProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cancelBag = CancelBag()
    private let viewModel: MyPageProfileViewModel
    
    private lazy var backButtonTapped = self.navigationBackButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    private lazy var duplicationCheckButtonTapped = self.originView.duplicationCheckButton.publisher(for: .touchUpInside).map { _ in
        return self.originView.nickNameTextField.text ?? ""
    }.eraseToAnyPublisher()
    private lazy var nextButtonTapped = self.originView.nextButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    // 3개의 기본 프로필 사진
    let basicProfileImages: [UIImage] = [
        ImageLiterals.Image.imgProfile1,
        ImageLiterals.Image.imgProfile2,
        ImageLiterals.Image.imgProfile3
    ]
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private let originView = MyPageEditProfileView()
    
    // MARK: - Life Cycles
    
    init(viewModel: MyPageProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        super.loadView()
        
        view = originView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
        setNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
}

// MARK: - Extensions

extension MyPageEditProfileViewController {
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
    
    private func setAddTarget() {
        self.originView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        self.originView.changeButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTisChanged), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func bindViewModel() {
        let input = MyPageProfileViewModel.Input(
            backButtonTapped: backButtonTapped,
            duplicationCheckButtonTapped: duplicationCheckButtonTapped,
            nextButtonTapped: nextButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.pushOrPopViewController
            .receive(on: RunLoop.main)
            .sink { value in
                if value == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: self.cancelBag)
        
        output.isEnable
            .receive(on: RunLoop.main)
            .sink { isEnable in
                self.originView.nickNameTextField.resignFirstResponder()
                self.originView.nextButton.isEnabled = true
                if isEnable {
                    self.originView.duplicationCheckDescription.text = StringLiterals.MyPage.myPageProfileNicknameAvailable
                    self.originView.duplicationCheckDescription.textColor = .success
                } else {
                    self.originView.duplicationCheckDescription.text = StringLiterals.MyPage.myPageProfileNicknameAlreadyUsed
                    self.originView.duplicationCheckDescription.textColor = .error
                }
            }
            .store(in: self.cancelBag)
    }
    
    @objc
    private func textFieldTisChanged() {
        self.originView.nextButton.isEnabled = false
        self.originView.duplicationCheckDescription.text = StringLiterals.MyPage.myPageProfileNicknameInfo
        self.originView.duplicationCheckDescription.textColor = .gray600
    }
    
    @objc
    private func changeButtonTapped() {
        let randomIndex = Int.random(in: 0..<basicProfileImages.count)
        self.originView.profileImage.image = basicProfileImages[randomIndex]
        self.originView.profileImage.contentMode = .scaleAspectFill
        self.originView.profileImage.layer.cornerRadius = self.originView.profileImage.frame.size.width / 2
        self.originView.profileImage.clipsToBounds = true
    }
    
    @objc
    private func plusButtonTapped() {
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
    
    func authSettingOpen() {
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

extension MyPageEditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let selectedImage = results.first else { return }
        
        selectedImage.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self.originView.profileImage.image = image
                    self.originView.profileImage.contentMode = .scaleAspectFill
                    self.originView.profileImage.layer.cornerRadius = self.originView.profileImage.frame.size.width / 2
                    self.originView.profileImage.clipsToBounds = true
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
}
