//
//  ProfileRegisterViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//

import UIKit

final class ProfileRegisterViewController: NavigationViewController {

    // MARK: - Property

    private let lckYear: Int
    private let lckTeam: String
    private let useCase = FetchNicknameDuplicationUseCase(repository: AccountRepositoryImpl())
    private let cancelBag = CancelBag()
    private var defaultImage: String?
    private lazy var photoPickerHelper = PhotoPickerHelper(presentingViewController: self)

    var navigateToAgreement: ((String, Int, String, UIImage?, String?) -> Void)?

    // MARK: - UIComponent

    private let rootView = ProfileRegisterView()

    // MARK: - Life Cycle

    init(lckYear: Int, lckTeam: String) {
        self.lckYear = lckYear
        self.lckTeam = lckTeam

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
    }
}

// MARK: - Setup Method

private extension ProfileRegisterViewController {
    func setupView() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        defaultImage = rootView.defaultImageList[0].uppercased
        rootView.configureView()
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        rootView.switchButton.addTarget(self, action: #selector(switchButtonDidTap), for: .touchUpInside)
        rootView.addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        rootView.checkButton.addTarget(self, action: #selector(duplicationCheckButtonDidTap), for: .touchUpInside)
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
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

    @objc func duplicationCheckButtonDidTap() {
        rootView.nickNameTextField.endEditing(true)

        guard let text = rootView.nickNameTextField.text else { return }

        checkNicknameDuplication(text)
    }

    @objc func nextButtonDidTap() {
        guard let name = rootView.nickNameTextField.text else { return }

        AmplitudeManager.shared.trackEvent(tag: .clickNextProfileSignup)

        navigateToAgreement?(
            name,
            lckYear,
            lckTeam,
            defaultImage == nil ? rootView.profileImageView.image : nil,
            defaultImage
        )
    }
}

// MARK: - Helper Method

private extension ProfileRegisterViewController {
    func updateToDefaultImage() {
        rootView.configureDefaultImage()
        defaultImage = rootView.defaultImageList[0].uppercased
    }

    func updateProfileImage(_ image: UIImage) {
        rootView.profileImageView.image = image
        defaultImage = nil
    }

    func checkNicknameDuplication(_ nickname: String) {
        useCase.execute(nickname: nickname)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.updateNicknameDuplicationUI(isValid: completion == .finished)
                },
                receiveValue: { _ in }
            )
            .store(in: cancelBag)
    }

    func updateNicknameDuplicationUI(isValid: Bool) {
        rootView.conditiionLabel.text = isValid
            ? StringLiterals.ProfileSetting.checkVaildMessage
            : StringLiterals.ProfileSetting.checkDuplicateError
        rootView.conditiionLabel.textColor = isValid ? .success : .error
        rootView.nextButton.isUserInteractionEnabled = isValid
        rootView.nextButton.updateStyle(isValid ? .primary : .gray)
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

        let isValid = validateNickname(text)
        updateTextFieldUI(isValid: isValid, isEmpty: text.isEmpty)
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

// MARK: - Helper Method

private extension ProfileRegisterViewController {
    func validateNickname(_ text: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: Constant.nicknamePattern) else { return false }
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }

    func updateTextFieldUI(isValid: Bool, isEmpty: Bool) {
        let shouldEnableCheck = isValid && !isEmpty

        rootView.conditiionLabel.text = shouldEnableCheck || isEmpty
            ? StringLiterals.ProfileSetting.checkDefaultMessage
            : StringLiterals.ProfileSetting.checkInvaildError
        rootView.conditiionLabel.textColor = shouldEnableCheck || isEmpty ? .gray600 : .error
        rootView.checkButton.isUserInteractionEnabled = shouldEnableCheck
        rootView.checkButton.configuration?.baseForegroundColor = shouldEnableCheck ? .white : .gray600
        rootView.checkButton.configuration?.baseBackgroundColor = shouldEnableCheck ? .wableBlack : .gray200
        rootView.nextButton.updateStyle(.gray)
        rootView.nextButton.isUserInteractionEnabled = false
    }
}

// MARK: - Constant

private extension ProfileRegisterViewController {
    enum Constant {
        static let nicknamePattern = "^[ㄱ-ㅎ가-힣a-zA-Z0-9]+$"
        static let maxNicknameLength = 10
    }
}
