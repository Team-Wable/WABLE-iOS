//
//  JoinProfileView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

import SnapKit

final class JoinProfileView: UIView {

    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = StringLiterals.Join.JoinProfileTitle
        title.textColor = .wableBlack
        title.numberOfLines = 2
        title.font = .head0
        title.setTextWithLineHeight(text: title.text, lineHeight: 37.adjusted, alignment: .left)
        return title
    }()
    
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Join.JoinProfileSubTitle
        label.textColor = .gray600
        label.font = .body2
        return label
    }()
    
    let profileImage: UIImageView = {
        let profileImage = UIImageView()
        profileImage.image = ImageLiterals.Button.btnWrite
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        return profileImage
    }()
    
    let changeButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setImage(ImageLiterals.Icon.icChange, for: .normal)
        return plusButton
    }()
    
    let plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setImage(ImageLiterals.Icon.icProfileplus, for: .normal)
        return plusButton
    }()
    
    let nickNameTextField: UITextField = {
        let nickNameTextField = UITextField()
        nickNameTextField.placeholder = StringLiterals.Join.JoinProfilePlaceholder
        nickNameTextField.textAlignment = .left
        nickNameTextField.textColor = .gray500
        nickNameTextField.font = .body2
        nickNameTextField.backgroundColor = .gray200
        nickNameTextField.layer.cornerRadius = 6.adjusted
        nickNameTextField.setPlaceholderColor(.gray500)
        nickNameTextField.setLeftPaddingPoints(16.adjusted)
        nickNameTextField.setRightPaddingPoints(16.adjusted)
        return nickNameTextField
    }()
    
    let duplicationCheckButton: UIButton = {
        let duplicationCheckButton = UIButton()
        duplicationCheckButton.setTitle(StringLiterals.Join.JoinProfileCheckButtonTitle, for: .normal)
        duplicationCheckButton.setTitleColor(.gray600, for: .normal)
        duplicationCheckButton.backgroundColor = .gray200
        duplicationCheckButton.titleLabel?.font = .body3
        duplicationCheckButton.layer.cornerRadius = 6.adjusted
        duplicationCheckButton.layer.masksToBounds = true
        duplicationCheckButton.isEnabled = false
        return duplicationCheckButton
    }()
    
    let duplicationCheckDescription: UILabel = {
        let duplicationCheckDescription = UILabel()
        duplicationCheckDescription.text = StringLiterals.Join.JoinProfileNicknameInfo
        duplicationCheckDescription.textColor = .gray600
        duplicationCheckDescription.font = .caption2
        return duplicationCheckDescription
    }()
    
    let isNotValidNickname: UILabel = {
        let isNotValidNickname = UILabel()
        isNotValidNickname.text = StringLiterals.Join.JoinProfileNicknameNotInclude
        isNotValidNickname.textColor = .error
        isNotValidNickname.font = .caption2
        isNotValidNickname.isHidden = true
        return isNotValidNickname
    }()
    
    let nextButton: UIButton = {
        let button = WableButton(type: .large, title: StringLiterals.Join.JoinNextButtonTitle, isEnabled: false)
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
        setDelegate()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension JoinProfileView {
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         subTitleLabel,
                         profileImage,
                         changeButton,
                         plusButton,
                         nickNameTextField,
                         duplicationCheckButton,
                         duplicationCheckDescription,
                         isNotValidNickname,
                         nextButton)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(110.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6.adjustedH)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        profileImage.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(48.adjustedH)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(166.adjusted)
        }
        
        changeButton.snp.makeConstraints {
            $0.leading.equalTo(profileImage.snp.leading).offset(-2.adjusted)
            $0.bottom.equalTo(profileImage.snp.bottom).offset(-12.adjusted)
            $0.size.equalTo(48.adjusted)
        }
        
        plusButton.snp.makeConstraints {
            $0.trailing.equalTo(profileImage.snp.trailing).offset(2.adjusted)
            $0.bottom.equalTo(profileImage.snp.bottom).offset(-12.adjusted)
            $0.size.equalTo(48.adjusted)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(44.adjustedH)
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.trailing.equalTo(duplicationCheckButton.snp.leading).offset(-8.adjusted)
            $0.height.equalTo(48.adjusted)
        }
        
        duplicationCheckButton.snp.makeConstraints {
            $0.centerY.height.equalTo(nickNameTextField)
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.width.equalTo(94.adjusted)
            $0.height.equalTo(48.adjusted)
        }
        
        duplicationCheckDescription.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(9.adjustedH)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        isNotValidNickname.snp.makeConstraints {
            $0.top.leading.equalTo(duplicationCheckDescription)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
        }
    }
    
    private func setDelegate() {
        self.nickNameTextField.delegate = self
    }
}

// MARK: - UITextFieldDelegate

extension JoinProfileView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // 키보드 내리면서 동작
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 10 // 글자수 제한
        let oldText = textField.text ?? "" // 입력하기 전 textField에 표시되어있던 text
        let addedText = string // 입력한 text
        let newText = oldText + addedText // 입력하기 전 text와 입력한 후 text를 합침
        let newTextLength = newText.count // 합쳐진 text의 길이
        
        // 글자수 제한
        if newTextLength <= maxLength {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? "" // textField에 수정이 반영된 후의 text
        
        let isValid = isValidInput(text)
        if isValid {
            duplicationCheckButton.isEnabled = true
            duplicationCheckButton.setTitleColor(.gray100, for: .normal)
            duplicationCheckButton.backgroundColor = .gray900
        } else {
            duplicationCheckButton.isEnabled = false
            duplicationCheckButton.setTitleColor(.gray600, for: .normal)
            duplicationCheckButton.backgroundColor = .gray200
        }
        
        duplicationCheckDescription.isHidden = !isValid
        isNotValidNickname.isHidden = isValid
        
        if text == "" {
            duplicationCheckDescription.isHidden = false
            isNotValidNickname.isHidden = true
        }
    }
}
