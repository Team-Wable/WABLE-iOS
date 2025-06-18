//
//  ProfileEditViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//

import Photos
import PhotosUI
import UIKit

final class ProfileEditViewController: NavigationViewController {
    
    // MARK: Property
    // TODO: 유즈케이스 리팩 후에 뷰모델 만들어 넘기기
    
    private let profileUseCase = UserProfileUseCase(repository: ProfileRepositoryImpl())
    private let nicknameUseCase = FetchNicknameDuplicationUseCase(repository: AccountRepositoryImpl())
    private let userSessionUseCase = FetchUserInformationUseCase(
        repository: UserSessionRepositoryImpl(
            userDefaults: UserDefaultsStorage(
                jsonEncoder: JSONEncoder(),
                jsonDecoder: JSONDecoder()
            )
        )
    )
    private let cancelBag = CancelBag()
    
    private var lckTeam = "LCK"
    private var sessionProfile: UserProfile? = nil
    private var defaultImage: String? = nil
    private var hasUserSelectedImage = false
    
    // MARK: - UIComponent
    
    private lazy var rootView = ProfileEditView(cellTapped: { [weak self] selectedTeam in
        guard let self = self else { return }
        
        lckTeam = selectedTeam
    })
    
    // MARK: - LifeCycle
    
    init() {
        super.init(type: .page(type: .profileEdit, title: "프로필 편집"))
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDelegate()
        setupAction()
        setupTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateSessionInfo()
        rootView.nickNameTextField.text = nil
        hasUserSelectedImage = false
        defaultImage = nil
    }
}

// MARK: - Priviate Extension

private extension ProfileEditViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(rootView)
        
        hidesBottomBarWhenPushed = true
    }
    
    func setupConstraint() {
        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupDelegate() {
        rootView.nickNameTextField.delegate = self
    }
    
    func setupAction() {
        rootView.switchButton.addTarget(self, action: #selector(switchButtonDidTap), for: .touchUpInside)
        rootView.addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        rootView.duplicationCheckButton.addTarget(self, action: #selector(duplicationCheckButtonDidTap), for: .touchUpInside)
        navigationView.doneButton.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - @objc Method
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func doneButtonDidTap() {
        guard let profile = sessionProfile else { return }
        
        let nicknameText = rootView.nickNameTextField.text ?? ""
        let hasNicknameChanged = !nicknameText.isEmpty && nicknameText != profile.user.nickname
        let hasImageChanged = defaultImage != nil || hasUserSelectedImage
        let hasTeamChanged = lckTeam != (profile.user.fanTeam?.rawValue ?? "LCK")
        
        if hasNicknameChanged || hasImageChanged || hasTeamChanged {
            let finalNickname = hasNicknameChanged ? nicknameText : profile.user.nickname
            
            profileUseCase.execute(
                profile: UserProfile(
                    user: User(
                        id: profile.user.id,
                        nickname: finalNickname,
                        profileURL: profile.user.profileURL,
                        fanTeam: LCKTeam(rawValue: lckTeam)
                    ),
                    introduction: profile.introduction,
                    ghostCount: profile.ghostCount,
                    lckYears: profile.lckYears,
                    userLevel: profile.userLevel
                ),
                image: defaultImage == nil ? rootView.profileImageView.image : nil,
                defaultProfileType: defaultImage
            )
            .withUnretained(self)
            .sink { _ in
            } receiveValue: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: cancelBag)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func switchButtonDidTap() {
        rootView.configureDefaultImage()
        defaultImage = rootView.defaultImageList[0].uppercased
        hasUserSelectedImage = false
        updateDoneButtonState()
    }
    
    @objc func addButtonDidTap() {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .denied, .restricted:
            presentSettings()
        case .authorized, .limited:
            presentPhotoPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    status == .authorized ? self.presentPhotoPicker() : nil
                }
            }
        default:
            break
        }
    }
    
    @objc func duplicationCheckButtonDidTap() {
        rootView.nickNameTextField.endEditing(true)
        
        guard let text = rootView.nickNameTextField.text else { return }

        nicknameUseCase.execute(nickname: text)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                let condition = completion == .finished
                
                self?.rootView.conditionLabel.text = condition ? StringLiterals.ProfileSetting.checkVaildMessage : StringLiterals.ProfileSetting.checkDuplicateError
                self?.rootView.conditionLabel.textColor = condition ? .success : .error
                self?.navigationView.doneButton.isUserInteractionEnabled = condition
                self?.navigationView.doneButton.updateStyle(condition ? .primary : .gray)
            }, receiveValue: { _ in
            })
            .store(in: cancelBag)
    }
    
    // MARK: - Function Method
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func presentSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        let alert = UIAlertController(
            title: "설정",
            message: StringLiterals.Empty.photoPermission,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        alert.addAction(UIAlertAction(title: "권한 설정하기", style: .default) { _ in
            UIApplication.shared.open(url)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateDoneButtonState() {
        guard let profile = sessionProfile else { return }
        
        let nicknameText = rootView.nickNameTextField.text ?? ""
        let hasNicknameChanged = !nicknameText.isEmpty && nicknameText != profile.user.nickname
        let hasImageChanged = defaultImage != nil || hasUserSelectedImage
        
        let shouldEnable = hasNicknameChanged || hasImageChanged
        
        navigationView.doneButton.isUserInteractionEnabled = shouldEnable
        navigationView.doneButton.updateStyle(shouldEnable ? .primary : .gray)
    }
}

extension ProfileEditViewController {
    func updateSessionInfo() {
        userSessionUseCase.fetchActiveUserID()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionID in
                guard let self = self,
                      let sessionID = sessionID else { return }
                
                profileUseCase.execute(userID: sessionID)
                    .receive(on: DispatchQueue.main)
                    .sink { _ in } receiveValue: { [weak self] profile in
                        guard let self = self else { return }
                        
                        self.sessionProfile = profile
                        self.rootView.configureView(
                            profileImageURL: profile.user.profileURL,
                            team: profile.user.fanTeam
                        )
                    }
                    .store(in: cancelBag)
            }
            .store(in: cancelBag)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProfileEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
            guard let image = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.rootView.profileImageView.image = image
                self.defaultImage = nil
                self.hasUserSelectedImage = true
                self.updateDoneButtonState()
            }
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let regex = try? NSRegularExpression(pattern: "^[ㄱ-ㅎ가-힣a-zA-Z0-9]+$")
        let range = NSRange(location: 0, length: text.utf16.count)
        let condition = regex?.firstMatch(in: text, options: [], range: range) != nil
        
        self.rootView.conditionLabel.text = condition || text == "" ? StringLiterals.ProfileSetting.checkDefaultMessage : StringLiterals.ProfileSetting.checkInvaildError
        self.rootView.conditionLabel.textColor = condition || text == "" ? .gray600 : .error
        self.rootView.duplicationCheckButton.isUserInteractionEnabled = condition
        self.rootView.duplicationCheckButton.configuration?.baseForegroundColor = condition ? .white : .gray600
        self.rootView.duplicationCheckButton.configuration?.baseBackgroundColor = condition ? .wableBlack : .gray200
        self.navigationView.doneButton.updateStyle(.gray)
        self.navigationView.doneButton.isUserInteractionEnabled = false
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else { return false }
        
        return string.isEmpty || (text + string).count <= 10
    }
}
