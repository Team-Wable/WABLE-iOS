//
//  WriteTextView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/23/24.
//

import UIKit

import SnapKit

final class WriteTextView: UIView {

    // MARK: - Properties
    
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy) // 햅틱 기능
    var currentTextLength = 0 // 현재 글자 수
    let maxLength = 500 // 최대 글자 수
    var isHiddenLinkView = true
    var isValidURL = false
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .head1
        textField.textColor = .wableBlack
        textField.backgroundColor = .clear
        textField.placeholder = StringLiterals.Write.writeTitlePlaceholder
        textField.setPlaceholderColor(.gray700)
        textField.borderStyle = .none
        textField.textAlignment = .left
        return textField
    }()
    
    let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .body2
        textView.textColor = .gray800
        textView.backgroundColor = .clear
        textView.addPlaceholder(StringLiterals.Write.writeContentPlaceholder, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 0
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.showsVerticalScrollIndicator = false
        return textView
    }()
    
    var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.adjusted
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var removePhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnRemovePhoto, for: .normal)
        return button
    }()
    
    let keyboardToolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableWhite
        view.layer.borderWidth = 1.adjusted
        view.layer.borderColor = UIColor.gray100.cgColor
        return view
    }()
    
    public let photoButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Icon.icPhoto, for: .normal)
        return button
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption4
        label.text = "0/500"
        label.textColor = .gray600
        return label
    }()
    
    public let postButton: UIButton = {
        let button = UIButton()
        button.setTitle(StringLiterals.Write.writePostButtonTitle, for: .normal)
        button.setTitleColor(.gray600, for: .normal)
        button.titleLabel?.font = UIFont.body3
        button.backgroundColor = .gray200
        button.layer.cornerRadius = 18.adjusted
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setDelegate()
        setUI()
        setHierarchy()
        setLayout()
        setAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension WriteTextView {
    func setDelegate() {
        self.titleTextField.delegate = self
        self.contentTextView.delegate = self
    }
    
    func setUI() {
        if UserDefaults.standard.integer(forKey: "memberGhost") > -85 {
            titleTextField.becomeFirstResponder()
        }
        // 햅틱 피드백 생성
        impactFeedbackGenerator.prepare()
    }
    
    func setHierarchy() {
        self.addSubviews(scrollView,
                         keyboardToolbarView)
        
        scrollView.addSubviews(contentView)
        
        contentView.addSubviews(titleTextField,
                                photoImageView,
                                contentTextView)
        
        photoImageView.addSubview(removePhotoButton)
        removePhotoButton.bringSubviewToFront(photoImageView)
        
        keyboardToolbarView.addSubviews(photoButton,
                                        textCountLabel,
                                        postButton)
    }
    
    func setLayout() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentTextView.snp.bottom)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(22.adjusted)
            $0.leading.trailing.equalToSuperview().inset(24.adjusted)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(24.adjusted)
            $0.bottom.equalTo(self.keyboardToolbarView.snp.top)
        }
        
        photoImageView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(24.adjusted)
            $0.height.equalTo(253.adjusted)
        }
        
        removePhotoButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(16.adjusted)
            $0.size.equalTo(44)
        }
        
        keyboardToolbarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.adjusted)
            $0.bottom.equalTo(self.keyboardLayoutGuide.snp.top)
        }
        
        photoButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.size.equalTo(32.adjusted)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(postButton.snp.leading).offset(-16.adjusted)
        }
        
        postButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.width.equalTo(53.adjusted)
            $0.height.equalTo(34.adjusted)
        }
    }
    
    func setAddTarget() {
        removePhotoButton.addTarget(self, action: #selector(removePhotoButtonTapped), for: .touchUpInside)
    }
    
    @objc private func removePhotoButtonTapped() {
        photoImageView.isHidden = true
        photoImageView.image = nil
        
        contentTextView.snp.remakeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(24.adjusted)
            $0.bottom.equalTo(self.keyboardToolbarView.snp.top)
        }
    }
}

extension WriteTextView: UITextFieldDelegate {
    
    // UITextFieldDelegate 메서드
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let titleTextLength = updatedText.count
        let contentTextLength = contentTextView.text.count
        self.currentTextLength = titleTextLength + contentTextLength
        
        if self.currentTextLength == 0 {
            postButton.setTitleColor(.gray600, for: .normal)
            postButton.backgroundColor = .gray200
            postButton.isEnabled = false
            textCountLabel.textColor = .gray600
        } else {
            if self.currentTextLength < 500 && titleTextLength != 0 {
                postButton.setTitleColor(.wableWhite, for: .normal)
                postButton.backgroundColor = .purple50
                postButton.isEnabled = true
                textCountLabel.textColor = .gray600
            } else if self.currentTextLength < 500 && titleTextLength == 0 {
                postButton.setTitleColor(.gray600, for: .normal)
                postButton.backgroundColor = .gray200
                postButton.isEnabled = false
                textCountLabel.textColor = .gray600
            } else if self.currentTextLength == 500 {
                postButton.setTitleColor(.gray600, for: .normal)
                postButton.backgroundColor = .gray200
                postButton.isEnabled = false
                textCountLabel.textColor = .error
                impactFeedbackGenerator.impactOccurred()
            } else {
                impactFeedbackGenerator.impactOccurred()
                return false
            }
        }
        
        textCountLabel.text = "\(self.currentTextLength)/\(self.maxLength)"
        
        return true
    }
}

extension WriteTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let titleTextLength = titleTextField.text?.count ?? 0
        let contentTextLength = contentTextView.text.count
        
        self.currentTextLength = titleTextLength + contentTextLength
        
        textView.text = String(textView.text.prefix(maxLength - titleTextLength))
        
        if self.currentTextLength == 0 {
            postButton.setTitleColor(.gray600, for: .normal)
            postButton.backgroundColor = .gray200
            postButton.isEnabled = false
            textCountLabel.textColor = .gray600
        } else {
            if self.currentTextLength < 500 && titleTextLength != 0 {
                postButton.setTitleColor(.wableWhite, for: .normal)
                postButton.backgroundColor = .purple50
                postButton.isEnabled = true
                textCountLabel.textColor = .gray600
            } else if self.currentTextLength < 500 && titleTextLength == 0 {
                postButton.setTitleColor(.gray600, for: .normal)
                postButton.backgroundColor = .gray200
                postButton.isEnabled = false
                textCountLabel.textColor = .gray600
            } else {
                self.currentTextLength = 500
                postButton.setTitleColor(.gray600, for: .normal)
                postButton.backgroundColor = .gray200
                postButton.isEnabled = false
                textCountLabel.textColor = .error
                impactFeedbackGenerator.impactOccurred()
            }
        }
        textCountLabel.text = "\(self.currentTextLength)/\(self.maxLength)"
    }
}
