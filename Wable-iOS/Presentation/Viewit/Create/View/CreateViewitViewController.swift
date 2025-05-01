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
    
    private let inputStackView = UIStackView(axis: .vertical)

    private let urlInputView = ViewitURLInputView()
    
    private let contentInputView = ViewitContentInputView().then {
        $0.isHidden = true
    }
    
    // MARK: - Property
    
    private let viewModel: ViewModel
    private let urlTextRelay = PassthroughRelay<String>()
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
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        urlInputView.urlTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.dimmedBackgroundView.backgroundColor = .wableBlack.withAlphaComponent(0.5)
        }
    }
}

private extension CreateViewitViewController {
    
    // MARK: - Setup Method

    func setupView() {
        inputStackView.addArrangedSubviews(urlInputView, contentInputView)
        
        view.addSubviews(
            dimmedBackgroundView,
            inputStackView
        )
        
        dimmedBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(inputStackView.snp.top)
        }
        
        let keyboardLayoutGuide = view.keyboardLayoutGuide
        inputStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap))
        dimmedBackgroundView.addGestureRecognizer(tapGesture)
        
        urlInputView.urlTextField.addTarget(self, action: #selector(urlTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            urlTextFieldDidChange: urlTextRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.nextButtonIsEnabled
            .sink { [weak self] isEnabled in
                let nextButton = self?.urlInputView.nextButton
                nextButton?.isEnabled = isEnabled
                nextButton?.tintColor = .blue50
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Action Method
    
    @objc func backgroundViewDidTap() {
        dismiss(animated: true)
    }
    
    @objc func urlTextFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        sender.backgroundColor = text.isEmpty ? .gray100 : .blue10
        urlTextRelay.send(text)
    }
}
