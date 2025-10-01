//
//  ProfileRegisterViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//

import Combine
import UIKit

final class ProfileRegisterViewController: NavigationViewController {

    // MARK: - Property

    var navigateToAgreement: ((OnboardingProfileInfo) -> Void)?

    private let cancelBag = CancelBag()
    private let viewModel: ProfileRegisterViewModel
    private let nicknameTextChangedRelay = PassthroughRelay<String>()
    private let nicknameDuplicationCheckRelay = PassthroughRelay<String>()

    private var profileImageType: ProfileImageType?
    private lazy var photoPickerHelper = PhotoPickerHelper(presentingViewController: self)

    // MARK: - UIComponent

    private let rootView = ProfileRegisterView()

    // MARK: - Life Cycle

    init(profileInfo: OnboardingProfileInfo) {
        self.viewModel = ProfileRegisterViewModel(profileInfo: profileInfo)

        super.init(type: .flow)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        setupDelegate()
        setupAction()
        setupBinding()
    }
}

// MARK: - Setup Method

private extension ProfileRegisterViewController {
    func setupView() {
        rootView.configureView()
        profileImageType = .default(rootView.currentDefaultImage)
    }

    func setupConstraints() {
        view.addSubview(rootView)

        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    func setupDelegate() {
        rootView.nickNameTextField.delegate = self
    }

    func setupAction() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        rootView.addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
        rootView.checkButton.addTarget(self, action: #selector(checkButtonDidTap), for: .touchUpInside)
        rootView.switchButton.addTarget(self, action: #selector(switchButtonDidTap), for: .touchUpInside)
    }

    func setupBinding() {
        let input = ProfileRegisterViewModel.Input(
            nicknameTextChanged: nicknameTextChangedRelay.eraseToAnyPublisher(),
            nicknameDuplicationCheckTrigger: nicknameDuplicationCheckRelay.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input, cancelBag: cancelBag)

        output.nicknameValidation
            .sink { [weak self] result in
                self?.updateTextField(validationResult: result)
            }
            .store(in: cancelBag)

        output.nicknameDuplicationResult
            .sink { [weak self] isValid in
                self?.updateDuplication(isValid: isValid)
            }
            .store(in: cancelBag)
    }
}

// MARK: - Action Method

private extension ProfileRegisterViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func switchButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickChangePictureProfileSignup)
        updateToDefaultImage()
    }

    @objc func addButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickAddPictureProfileSignup)
        photoPickerHelper.presentPhotoPicker { [weak self] image in
            self?.updateProfileImage(image)
        }
    }

    @objc func checkButtonDidTap() {
        rootView.nickNameTextField.endEditing(true)

        guard let text = rootView.nickNameTextField.text else { return }

        nicknameDuplicationCheckRelay.send(text)
    }

    @objc func nextButtonDidTap() {
        guard let name = rootView.nickNameTextField.text else { return }
        let updatedProfileInfo = viewModel.getProfileInfo(nickname: name, profileImageType: profileImageType)

        AmplitudeManager.shared.trackEvent(tag: .clickNextProfileSignup)
        navigateToAgreement?(updatedProfileInfo)
    }
}

// MARK: - Helper Method

private extension ProfileRegisterViewController {
    func updateToDefaultImage() {
        rootView.configureDefaultImage()
        profileImageType = .default(rootView.currentDefaultImage)
    }

    func updateProfileImage(_ image: UIImage) {
        rootView.profileImageView.image = image
        profileImageType = .custom(image)
    }

    func updateDuplication(isValid: Bool) {
        rootView.conditiionLabel.text = isValid
            ? StringLiterals.ProfileSetting.checkVaildMessage
            : StringLiterals.ProfileSetting.checkDuplicateError
        rootView.conditiionLabel.textColor = isValid ? .success : .error
        rootView.nextButton.isUserInteractionEnabled = isValid
        rootView.nextButton.updateStyle(isValid ? .primary : .gray)
    }

    func updateTextField(validationResult: NicknameValidationResult) {
        switch validationResult {
        case .empty:
            rootView.conditiionLabel.text = StringLiterals.ProfileSetting.checkDefaultMessage
            rootView.conditiionLabel.textColor = .gray600
            rootView.checkButton.isUserInteractionEnabled = false
            rootView.checkButton.configuration?.baseForegroundColor = .gray600
            rootView.checkButton.configuration?.baseBackgroundColor = .gray200
        case .valid:
            rootView.conditiionLabel.text = StringLiterals.ProfileSetting.checkDefaultMessage
            rootView.conditiionLabel.textColor = .gray600
            rootView.checkButton.isUserInteractionEnabled = true
            rootView.checkButton.configuration?.baseForegroundColor = .white
            rootView.checkButton.configuration?.baseBackgroundColor = .wableBlack
        case .invalidFormat:
            rootView.conditiionLabel.text = StringLiterals.ProfileSetting.checkInvaildError
            rootView.conditiionLabel.textColor = .error
            rootView.checkButton.isUserInteractionEnabled = false
            rootView.checkButton.configuration?.baseForegroundColor = .gray600
            rootView.checkButton.configuration?.baseBackgroundColor = .gray200
        }

        rootView.nextButton.updateStyle(.gray)
        rootView.nextButton.isUserInteractionEnabled = false
    }
}

// MARK: - UITextFieldDelegate

extension ProfileRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        nicknameTextChangedRelay.send(text)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else { return false }
        return string.isEmpty || (text + string).count <= Constant.maxNicknameLength
    }
}

// MARK: - Constant

private extension ProfileRegisterViewController {
    enum Constant {
        static let maxNicknameLength = 10
    }
}
