//
//  ViewitInputView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/4/25.
//

import Combine
import UIKit

import SnapKit
import Then
import Lottie

final class ViewitInputView: UIView {
    
    // MARK: - UIComponent

    private let urlInputContainerView = UIView()
    
    let imageBackgroundView = UIView().then {
        $0.isHidden = true
    }
    
    let urlIconImageView = UIImageView(image: .icLink)
    
    let urlTextField = UITextField(pretendard: .body4, placeholder: Constant.urlPlaceholder).then {
        $0.tintColor = .purple50
        $0.textColor = .blue50
        $0.backgroundColor = .gray100
        $0.layer.cornerRadius = 16
        $0.addPadding(left: 8, right: 8)
        $0.keyboardType = .URL
        $0.autocapitalizationType = .none
    }
    
    let buttonBackgroundView = UIView().then {
        $0.isHidden = false
    }
    
    let nextButton = UIButton().then {
        $0.setImage(.btnLink.withRenderingMode(.alwaysOriginal), for: .disabled)
        $0.setImage(.btnLinkPress, for: .normal)
        $0.isEnabled = false
    }
    
    let descriptionInputContainerView = UIView().then {
        $0.isHidden = true
    }
    
    let descriptionTextField = UITextField(pretendard: .body4, placeholder: Constant.descriptionPlaceholder).then {
        $0.tintColor = .purple50
        $0.backgroundColor = .gray100
        $0.layer.borderColor = UIColor.gray100.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 16
        $0.addPadding(left: 8, right: 8)
        $0.autocapitalizationType = .none
    }
    
    let uploadButton = UIButton().then {
        $0.setImage(.btnRippleDefault, for: .disabled)
        $0.setImage(.btnRipplePress, for: .normal)
        $0.isEnabled = false
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .wableWhite
        
        setupView()
        setupURLInputView()
        setupDescriptionInputView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewitInputView {
    var urlStringChanged: AnyPublisher<String, Never> {
        urlTextField
            .publisher(for: .editingChanged, keyPath: \.text)
            .compactMap { $0 }
            .handleEvents(receiveOutput: { [weak self] text in
                self?.urlTextField.backgroundColor = text.isEmpty ? .gray100 : .blue10
            })
            .eraseToAnyPublisher()
    }
    
    var nextTapped: AnyPublisher<Void, Never> {
        nextButton
            .publisher(for: .touchUpInside)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var descriptionChanged: AnyPublisher<String, Never> {
        descriptionTextField
            .publisher(for: .editingChanged, keyPath: \.text)
            .compactMap { $0 }
            .handleEvents(receiveOutput: { [weak self] text in
                self?.descriptionTextField.backgroundColor = text.isEmpty ? .gray100 : .wableWhite
            })
            .eraseToAnyPublisher()
    }
    
    var uploadTapped: AnyPublisher<Void, Never> {
        uploadButton
            .publisher(for: .touchUpInside)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

private extension ViewitInputView {
    
    // MARK: - Setup Method

    func setupView() {
        let mainStackView = UIStackView(
            arrangedSubviews: [urlInputContainerView, descriptionInputContainerView]
        ).then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupURLInputView() {
        imageBackgroundView.addSubview(urlIconImageView)
        buttonBackgroundView.addSubview(nextButton)
        
        let urlStackView = UIStackView(
            arrangedSubviews: [imageBackgroundView, urlTextField, buttonBackgroundView]
        ).then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        urlInputContainerView.addSubview(urlStackView)
        
        urlStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        urlIconImageView.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
            make.size.equalTo(Constant.buttonSize)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.adjustedHeightEqualTo(Constant.textFieldHeight)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.size.equalTo(Constant.buttonSize)
        }
    }
    
    func setupDescriptionInputView() {
        let topAnimationView = LottieAnimationView(name: LottieType.tab.rawValue).then {
            $0.contentMode = .scaleAspectFill
            $0.loopMode = .loop
            $0.play()
        }
        
        descriptionInputContainerView.addSubviews(topAnimationView, descriptionTextField, uploadButton)
        
        topAnimationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(2)
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(16)
            make.adjustedHeightEqualTo(Constant.textFieldHeight)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(descriptionTextField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.size.equalTo(Constant.buttonSize)
        }
    }
    
    // MARK: - Constant
    
    enum Constant {
        static let urlPlaceholder = "공유하고 싶은 동영상 링크를 입력해주세요."
        static let descriptionPlaceholder = "어떤 내용의 링크인가요?"
        static let textFieldHeight: CGFloat = 40
        static let buttonSize: CGFloat = 32
    }
}
