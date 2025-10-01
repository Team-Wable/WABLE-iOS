//
//  ProfileEditViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//

import Combine
import Photos
import PhotosUI
import UIKit

final class ProfileEditViewController: NavigationViewController {

    // MARK: Property

    private let cancelBag = CancelBag()
    private let viewModel: ProfileEditViewModel
    private let viewWillAppearRelay = PassthroughRelay<Void>()
    private let nicknameTextChangedRelay = PassthroughRelay<String>()
    private let nicknameDuplicationCheckRelay = PassthroughRelay<String>()
    private let lckTeamChangedRelay = PassthroughRelay<String>()
    private let profileImageChangedRelay = PassthroughRelay<ProfileImageType>()
    private let saveButtonTappedRelay = PassthroughRelay<String>()

    private lazy var photoPickerHelper = PhotoPickerHelper(presentingViewController: self)

    // MARK: - UIComponent

    private lazy var rootView = ProfileEditView(cellTapped: { [weak self] selectedTeam in
        self?.lckTeamChangedRelay.send(selectedTeam)
    })
    
    // MARK: - LifeCycle

    init(userID: Int) {
        self.viewModel = ProfileEditViewModel(userID: userID)

        super.init(type: .page(type: .profileEdit, title: "프로필 편집"))

        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        setupDelegate()
        setupAction()
        setupTapGesture()
        setupBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewWillAppearRelay.send()
        rootView.nickNameTextField.text = nil
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
    
    func setupConstraints() {
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

    func setupBinding() {
        let input = ProfileEditViewModel.Input(
            viewWillAppear: viewWillAppearRelay.eraseToAnyPublisher(),
            nicknameTextChanged: nicknameTextChangedRelay.eraseToAnyPublisher(),
            nicknameDuplicationCheckTrigger: nicknameDuplicationCheckRelay.eraseToAnyPublisher(),
            lckTeamChanged: lckTeamChangedRelay.eraseToAnyPublisher(),
            profileImageChanged: profileImageChangedRelay.eraseToAnyPublisher(),
            saveButtonTapped: saveButtonTappedRelay.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input, cancelBag: cancelBag)

        output.profileLoaded
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, profile in
                owner.rootView.configureView(
                    profileImageURL: profile.user.profileURL,
                    team: profile.user.fanTeam
                )
            }
            .store(in: cancelBag)

        output.nicknameValidation
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, result in
                owner.updateTextField(validationResult: result)
            }
            .store(in: cancelBag)

        output.nicknameDuplicationResult
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isValid in
                owner.updateDuplication(isValid: isValid)
            }
            .store(in: cancelBag)

        output.profileUpdateCompleted
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: cancelBag)
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
        let nickname = rootView.nickNameTextField.text ?? ""
        saveButtonTappedRelay.send(nickname)
    }
    
    @objc func switchButtonDidTap() {
        rootView.configureDefaultImage()
        profileImageChangedRelay.send(.default(rootView.currentDefaultImage))
    }

    @objc func addButtonDidTap() {
        photoPickerHelper.presentPhotoPicker { [weak self] image in
            guard let self else { return }

            self.rootView.profileImageView.image = image
            self.profileImageChangedRelay.send(.custom(image))
        }
    }
    
    @objc func duplicationCheckButtonDidTap() {
        rootView.nickNameTextField.endEditing(true)

        guard let text = rootView.nickNameTextField.text else { return }

        nicknameDuplicationCheckRelay.send(text)
    }
    
    // MARK: - Function Method

    func updateTextField(validationResult: NicknameValidationResult) {
        switch validationResult {
        case .empty:
            rootView.conditionLabel.text = StringLiterals.ProfileSetting.checkDefaultMessage
            rootView.conditionLabel.textColor = .gray600
            rootView.duplicationCheckButton.isUserInteractionEnabled = false
            rootView.duplicationCheckButton.configuration?.baseForegroundColor = .gray600
            rootView.duplicationCheckButton.configuration?.baseBackgroundColor = .gray200
        case .valid:
            rootView.conditionLabel.text = StringLiterals.ProfileSetting.checkDefaultMessage
            rootView.conditionLabel.textColor = .gray600
            rootView.duplicationCheckButton.isUserInteractionEnabled = true
            rootView.duplicationCheckButton.configuration?.baseForegroundColor = .white
            rootView.duplicationCheckButton.configuration?.baseBackgroundColor = .wableBlack
        case .invalidFormat:
            rootView.conditionLabel.text = StringLiterals.ProfileSetting.checkInvaildError
            rootView.conditionLabel.textColor = .error
            rootView.duplicationCheckButton.isUserInteractionEnabled = false
            rootView.duplicationCheckButton.configuration?.baseForegroundColor = .gray600
            rootView.duplicationCheckButton.configuration?.baseBackgroundColor = .gray200
        }

        navigationView.doneButton.updateStyle(.gray)
        navigationView.doneButton.isUserInteractionEnabled = false
    }

    func updateDuplication(isValid: Bool) {
        rootView.conditionLabel.text = isValid
            ? StringLiterals.ProfileSetting.checkVaildMessage
            : StringLiterals.ProfileSetting.checkDuplicateError
        rootView.conditionLabel.textColor = isValid ? .success : .error
        navigationView.doneButton.isUserInteractionEnabled = isValid
        navigationView.doneButton.updateStyle(isValid ? .primary : .gray)
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

        nicknameTextChangedRelay.send(text)
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
