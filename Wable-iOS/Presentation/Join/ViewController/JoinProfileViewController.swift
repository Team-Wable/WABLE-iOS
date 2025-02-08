//
//  JoinProfileViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit
import Photos
import PhotosUI

import CombineCocoa
import SnapKit

final class JoinProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cancelBag = CancelBag()
    private let viewModel: JoinProfileViewModel
    private let userInfo: UserInfoBuilder
    
    let basicProfileImages: [UIImage : String] = [
        ImageLiterals.Image.imgProfile1 : "PURPLE",
        ImageLiterals.Image.imgProfile2 : "BLUE",
        ImageLiterals.Image.imgProfile3 : "GREEN"
    ]
    
    // MARK: - UI Components
    
    private var navigationBackButton = BackButton()
    private var navigationXButton = XButton()
    private let originView = JoinProfileView()
    
    // MARK: - Life Cycles
    
    init(viewModel: JoinProfileViewModel, userInfo: UserInfoBuilder) {
        self.viewModel = viewModel
        self.userInfo = userInfo
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
        
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
        setNotification()
        dismissKeyboardTouchOutside()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.originView.profileImage.contentMode = .scaleAspectFill
        self.originView.profileImage.layer.cornerRadius = self.originView.profileImage.frame.size.width / 2
        self.originView.profileImage.clipsToBounds = true
    }
}

// MARK: - Private Method

private extension JoinProfileViewController {
    func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    func setHierarchy() {
        self.navigationController?.navigationBar.addSubviews(navigationBackButton, navigationXButton)
    }
    
    func setLayout() {
        navigationBackButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        
        navigationXButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12.adjusted)
        }
    }
    
    func setAddTarget() {
        navigationXButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        navigationBackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        originView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        originView.changeButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
        originView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldisChanged), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    func bindViewModel() {
        let duplicationCheckButtonTapped = self.originView.duplicationCheckButton.tapPublisher
            .map { [weak self] in
                self?.originView.nickNameTextField.text ?? ""
            }
            .eraseToAnyPublisher()
        
        let input = JoinProfileViewModel.Input(duplicationCheckButtonTapped: duplicationCheckButtonTapped)
        
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.isEnable
            .receive(on: RunLoop.main)
            .withUnretained(self)
            .sink { owner, isEnable in
                owner.originView.nickNameTextField.resignFirstResponder()
                owner.originView.nextButton.isEnabled = isEnable
                if isEnable {
                    owner.originView.duplicationCheckDescription.text = StringLiterals.Join.JoinProfileNicknameAvailable
                    owner.originView.duplicationCheckDescription.textColor = .success
                } else {
                    owner.originView.duplicationCheckDescription.text = StringLiterals.Join.JoinProfileNicknameAlreadyUsed
                    owner.originView.duplicationCheckDescription.textColor = .error
                }
            }
            .store(in: self.cancelBag)
    }
    
    @objc
    func textFieldisChanged() {
        self.originView.nextButton.isEnabled = false
        self.originView.duplicationCheckDescription.text = StringLiterals.Join.JoinProfileNicknameInfo
        self.originView.duplicationCheckDescription.textColor = .gray600
    }
    
    @objc
    func changeButtonTapped() {
        AmplitudeManager.shared.trackEvent(tag: "click_change_picture_profile_signup")
        let randomEntry = basicProfileImages.randomElement()
        
        if let selectedImage = randomEntry?.key, let selectedColor = randomEntry?.value {
            self.originView.profileImage.image = selectedImage
            userInfo
                .setMemberDefaultProfileImage(selectedColor)
                .setFile(nil)
        }
    }
    
    @objc
    func xButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = [LoginViewController(viewModel: MigratedLoginViewModel())]
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
    
    @objc
    func nextButtonTapped() {
        userInfo.setNickname(self.originView.nickNameTextField.text)
        let viewController = MigratedJoinAgreementViewController(viewModel: MigratedJoinAgreementViewModel(userInfo: userInfo))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func plusButtonTapped() {
        AmplitudeManager.shared.trackEvent(tag: "click_add_picture_profile_signup")
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
    
    @objc
    func keyboardUp(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            }
        }
    }
    
    @objc
    func keyboardDown(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
    
    func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
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

extension JoinProfileViewController: PHPickerViewControllerDelegate {
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

                    self.userInfo
                        .setMemberDefaultProfileImage("")
                        .setFile(image.jpegData(compressionQuality: 0.8))
                    
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
}
