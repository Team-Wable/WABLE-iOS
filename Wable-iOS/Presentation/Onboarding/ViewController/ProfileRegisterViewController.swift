//
//  ProfileRegisterViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//

import Photos
import PhotosUI
import UIKit

final class ProfileRegisterViewController: NavigationViewController {

    // MARK: - Property
    
    var navigateToAgreement: ((String, Int, String, UIImage?, String?) -> Void)?

    private let lckYear: Int
    private let lckTeam: String
    private let useCase = FetchNicknameDuplicationUseCase(repository: AccountRepositoryImpl())
    private let cancelBag = CancelBag()
    
    private var defaultImage: String?

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

// MARK: - Priviate Extension

private extension ProfileRegisterViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.addSubview(rootView)
        
        defaultImage = rootView.defaultImageList[0].uppercased
        
        rootView.configureView()
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
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - @objc Method
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func switchButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickChangePictureProfileSignup)
        
        rootView.configureDefaultImage()
        defaultImage = rootView.defaultImageList[0].uppercased
    }
    
    @objc func addButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickAddPictureProfileSignup)

        handlePhotoLibraryAuthorization()
    }

    @objc func duplicationCheckButtonDidTap() {
        rootView.nickNameTextField.endEditing(true)
        
        guard let text = rootView.nickNameTextField.text else { return }

        useCase.execute(nickname: text)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                let condition = completion == .finished
                
                self?.rootView.conditiionLabel.text = condition ? StringLiterals.ProfileSetting.checkVaildMessage : StringLiterals.ProfileSetting.checkDuplicateError
                self?.rootView.conditiionLabel.textColor = condition ? .success : .error
                self?.rootView.nextButton.isUserInteractionEnabled = condition
                self?.rootView.nextButton.updateStyle(condition ? .primary : .gray)
            }, receiveValue: { _ in
            })
            .store(in: cancelBag)
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
    
    // MARK: - Function Method
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }
}


// MARK: - PHPickerViewControllerDelegate

extension ProfileRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let image = image as? UIImage else { return }

            DispatchQueue.main.async {
                self?.rootView.profileImageView.image = image
                self?.defaultImage = nil
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension ProfileRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let range = NSRange(location: 0, length: text.utf16.count)
        let condition = regex?.firstMatch(in: text, options: [], range: range) != nil
        
        self.rootView.conditiionLabel.text = condition || text == "" ? StringLiterals.ProfileSetting.checkDefaultMessage : StringLiterals.ProfileSetting.checkInvaildError
        self.rootView.conditiionLabel.textColor = condition || text == "" ? .gray600 : .error
        self.rootView.duplicationCheckButton.isUserInteractionEnabled = condition
        self.rootView.duplicationCheckButton.configuration?.baseForegroundColor = condition ? .white : .gray600
        self.rootView.duplicationCheckButton.configuration?.baseBackgroundColor = condition ? .wableBlack : .gray200
        self.rootView.nextButton.updateStyle(.gray)
        self.rootView.nextButton.isUserInteractionEnabled = false
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
