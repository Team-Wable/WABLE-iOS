//
//  CreateViewitViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/1/25.
//

import UIKit

import SnapKit
import Then

final class CreateViewitViewController: UIViewController {
    
    // MARK: - typealias

    typealias ViewModel = CreateViewitViewModel

    // MARK: - UIComponent
    
    private let dimmedBackgroundView = UIView(backgroundColor: .wableBlack.withAlphaComponent(.zero))
    
    private let viewitInputView = ViewitInputView()
    
    // MARK: - Property
    
    var onFinishCreateViewit: (() -> Void)?
    
    private let viewModel: ViewModel
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .wableBlack.withAlphaComponent(.zero)
        
        setupView()
        setupDelegate()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewitInputView.urlTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.dimmedBackgroundView.backgroundColor = .wableBlack.withAlphaComponent(0.5)
        }
    }
}

// MARK: - UITextFieldDelegate

extension CreateViewitViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configure(isURLEditing: textField == viewitInputView.urlTextField)
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField == viewitInputView.descriptionTextField else {
            return true
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 50
    }
}
    
private extension CreateViewitViewController {
    
    // MARK: - Setup Method

    func setupView() {
        view.addSubviews(
            dimmedBackgroundView,
            viewitInputView
        )
        
        dimmedBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(viewitInputView.snp.top)
        }
        
        let keyboardLayoutGuide = view.keyboardLayoutGuide
        viewitInputView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
    }
    
    func setupDelegate() {
        viewitInputView.urlTextField.delegate = self
        viewitInputView.descriptionTextField.delegate = self
    }
    
    func setupBinding() {
        let urlInput = viewitInputView.urlTextField
            .publisher(for: .editingChanged, keyPath: \.text)
            .compactMap { $0 }
            .handleEvents(receiveOutput: { [weak self] text in
                self?.viewitInputView.urlTextField.backgroundColor = text.isEmpty ? .gray100 : .blue10
            })
            .eraseToAnyPublisher()
        
        let nextTapped = viewitInputView.nextButton
            .publisher(for: .touchUpInside)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let descriptionInput = viewitInputView.descriptionTextField
            .publisher(for: .editingChanged, keyPath: \.text)
            .compactMap { $0 }
            .handleEvents(receiveOutput: { [weak self] text in
                self?.viewitInputView.descriptionTextField.backgroundColor = text.isEmpty ? .gray100 : .wableWhite
            })
            .eraseToAnyPublisher()
        
        let uploadTapped = viewitInputView.uploadButton
            .publisher(for: .touchUpInside)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in AmplitudeManager.shared.trackEvent(tag: .clickUploadLinkpost) })
            .eraseToAnyPublisher()
        
        let input = ViewModel.Input(
            urlStringChanged: urlInput,
            next: nextTapped,
            descriptionChanged: descriptionInput,
            upload: uploadTapped,
            backgroundTap: dimmedBackgroundView.gesture().asVoid()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.enableNext
            .assign(to: \.isEnabled, on: viewitInputView.nextButton)
            .store(in: cancelBag)
        
        output.isPossibleToURLUpload
            .filter { $0 }
            .sink { [weak self] _ in
                self?.viewitInputView.descriptionTextField.becomeFirstResponder()
            }
            .store(in: cancelBag)
        
        output.enableUpload
            .assign(to: \.isEnabled, on: viewitInputView.uploadButton)
            .store(in: cancelBag)
        
        output.successUpload
            .sink { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.onFinishCreateViewit?()
                }
            }
            .store(in: cancelBag)
        
        output.showSheetBeforeDismiss
            .sink { [weak self] in
                $0 ? self?.presentExitSheet() : self?.dismiss(animated: true)
            }
            .store(in: cancelBag)
        
        output.errorMessage
            .sink { [weak self] message in
                let confirmAction = UIAlertAction(title: "확인", style: .default)
                self?.showAlert(title: "에러 발생!", message: message, actions: confirmAction)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Helper Method

    func configure(isURLEditing: Bool) {
        let textFieldAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.pretendard(isURLEditing ? .body4 : .body3),
            .foregroundColor: UIColor.blue50,
        ]
        
        if let text = viewitInputView.urlTextField.text {
            let mutableAttributedString = NSMutableAttributedString(string: text, attributes: textFieldAttributes)
            viewitInputView.urlTextField.attributedText = isURLEditing
            ? mutableAttributedString
            : mutableAttributedString.addUnderline()
        }
        
        viewitInputView.imageBackgroundView.isHidden = isURLEditing
        viewitInputView.buttonBackgroundView.isHidden = !isURLEditing
        UIView.animate(withDuration: 0.2) {
            self.viewitInputView.descriptionInputContainerView.isHidden = isURLEditing
        }
    }
    
    func presentExitSheet() {
        let exitAction = WableSheetAction(title: "나가기", style: .primary) { [weak self] in
            self?.dismiss(animated: true)
        }
        showWableSheetWithCancel(title: StringLiterals.Exit.sheetTitle, action: exitAction)
    }
}
