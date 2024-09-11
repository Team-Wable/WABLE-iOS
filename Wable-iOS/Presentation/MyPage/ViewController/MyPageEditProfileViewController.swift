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
    
    private lazy var duplicationCheckButtonTapped = self.originView.duplicationCheckButton.publisher(for: .touchUpInside).map { _ in
        return self.originView.nickNameTextField.text ?? ""
    }.eraseToAnyPublisher()
    private lazy var nextButtonTapped = self.originView.nextButton.publisher(for: .touchUpInside).map { _ in
        return UserProfileUnionRequestDTO(
            info: UserProfileRequestDTO(
                nickname: self.originView.nickNameTextField.text,
                memberDefaultProfileImage: self.memberDefaultProfileImage),
            file: self.memberProfileImage?.jpegData(compressionQuality: 0.8)!
        )
    }.eraseToAnyPublisher()
    
    // 3개의 기본 프로필 사진
    let basicProfileImages: [UIImage : String] = [
        ImageLiterals.Image.imgProfile1 : "PURPLE",
        ImageLiterals.Image.imgProfile2 : "BLUE",
        ImageLiterals.Image.imgProfile3 : "GREEN"
    ]
    
    private var previousSelectedImage: String?
    var memberDefaultProfileImage: String?
    var memberProfileImage: UIImage?
    
    // MARK: - UI Components
    
    private let originView = MyPageEditProfileView()
    private let topDivisionLine = UIView().makeDivisionLine()
    
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
        setNavigationBar()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.originView.profileImage.contentMode = .scaleAspectFill
        self.originView.profileImage.layer.cornerRadius = self.originView.profileImage.frame.size.width / 2
        self.originView.profileImage.clipsToBounds = true
    }
}

// MARK: - Extensions

extension MyPageEditProfileViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        self.originView.nickNameTextField.text = loadUserData()?.userNickname
        self.originView.profileImage.load(url: loadUserData()?.userProfileImage ?? "")
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
    
    private func setAddTarget() {
        self.originView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        self.originView.changeButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTisChanged), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        self.title = "프로필 편집"
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc
    private func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func bindViewModel() {
        let input = MyPageProfileViewModel.Input(
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
                if isEnable {
                    self.originView.duplicationCheckDescription.text = StringLiterals.MyPage.myPageProfileNicknameAvailable
                    self.originView.duplicationCheckDescription.textColor = .success
                    self.originView.nextButton.isEnabled = true
                    self.originView.isCheckedNickname = true
                } else {
                    self.originView.duplicationCheckDescription.text = StringLiterals.MyPage.myPageProfileNicknameAlreadyUsed
                    self.originView.duplicationCheckDescription.textColor = .error
                    self.originView.nextButton.isEnabled = false
                    self.originView.isCheckedNickname = false
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
        // 이전에 선택된 이미지를 제외한 무작위 항목 선택
        if let randomEntry = basicProfileImages.filter({ $0.value != previousSelectedImage }).randomElement() {
            let selectedImage = randomEntry.key
            let selectedColor = randomEntry.value
            
            // 프로필 이미지 변경
            self.originView.profileImage.image = selectedImage
            self.memberDefaultProfileImage = selectedColor
            self.memberProfileImage = nil
            
            // 현재 선택된 이미지를 저장하여 다음에 제외
            previousSelectedImage = selectedColor
        }
        
        if self.originView.isCheckedNickname == true {
            self.originView.nextButton.isEnabled = true
        }
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
                    
                    self.memberProfileImage = image
                    self.memberDefaultProfileImage = ""
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
}
