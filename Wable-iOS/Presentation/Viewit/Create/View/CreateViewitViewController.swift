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
    
    private let viewModel: ViewModel
    private let urlTextRelay = PassthroughRelay<String>()
    private let contentTextRelay = PassthroughRelay<String>()
    private let uploadButtonRelay = PassthroughRelay<Void>()
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
        setupAction()
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
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap))
        dimmedBackgroundView.addGestureRecognizer(tapGesture)
        
        viewitInputView.urlTextField.addTarget(self, action: #selector(urlTextFieldDidChange(_:)), for: .editingChanged)
        viewitInputView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
        viewitInputView.descriptionTextField.addTarget(
            self,
            action: #selector(contentTextFieldDidChange(_:)),
            for: .editingChanged
        )
        
        // TODO: Upload버튼 액션 설정
        
    }
    
    func setupDelegate() {
        viewitInputView.urlTextField.delegate = self
        viewitInputView.descriptionTextField.delegate = self
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            urlStringChanged: urlTextRelay.eraseToAnyPublisher(),
            descriptionChanged: contentTextRelay.eraseToAnyPublisher(),
            upload: uploadButtonRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.enableNext
            .assign(to: \.isEnabled, on: viewitInputView.nextButton)
            .store(in: cancelBag)
        
        output.enableUpload
            .assign(to: \.isEnabled, on: viewitInputView.uploadButton)
            .store(in: cancelBag)
        
        output.successUpload
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: cancelBag)
        
        output.errorMessage
            .sink { [weak self] message in
                let alertController = UIAlertController(title: "에러 발생!", message: message, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "확인", style: .default)
                alertController.addAction(confirmAction)
                self?.present(alertController, animated: true)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Action Method
    
    @objc func backgroundViewDidTap() {
        let wableSheetViewController = WableSheetViewController(title: Constant.wableSheetTitle, message: nil)
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let confirmAction = WableSheetAction(title: "나가기", style: .primary) { [weak self] in
            self?.dismiss(animated: true)
        }
        wableSheetViewController.addActions(cancelAction, confirmAction)
        present(wableSheetViewController, animated: true)
    }
    
    @objc func urlTextFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        sender.backgroundColor = text.isEmpty ? .gray100 : .blue10
        urlTextRelay.send(text)
    }
    
    @objc func nextButtonDidTap() {
        viewitInputView.descriptionTextField.becomeFirstResponder()
    }
    
    @objc func contentTextFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        sender.backgroundColor = text.isEmpty ? .gray100 : .wableWhite
        contentTextRelay.send(text)
    }
    
    @objc func uploadButtonDidTap() {
        uploadButtonRelay.send()
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
    
    // MARK: - Constant
    
    enum Constant {
        static let wableSheetTitle = "작성중인 글에서 나가실건가요?\n작성하셨던 내용은 삭제돼요"
    }
}
