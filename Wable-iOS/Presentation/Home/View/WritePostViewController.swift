//
//  WritePostViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//


import Combine
import UIKit
import PhotosUI

final class WritePostViewController: NavigationViewController {
    
    // MARK: - Property
    
    private let viewModel: WritePostViewModel
    private let postButtonTapRelay = PassthroughRelay<(title: String, content: String?, image: UIImage?)>()
    private var cancelBag = CancelBag()
    
    // MARK: - UIComponents
    
    private let scrollView: UIScrollView = .init().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let stackView: UIStackView = .init(axis: .vertical).then {
        $0.spacing = 12
    }
    
    private lazy var titleTextView: UITextView = .init().then {
        $0.isScrollEnabled = false
        $0.textContainerInset = .zero
        $0.setPretendard(with: .head1, text: Constant.titlePlaceholder)
        $0.textColor = .gray500
        $0.backgroundColor = .clear
    }
    
    private lazy var contentTextView: UITextView = .init().then {
        $0.isScrollEnabled = false
        $0.textContainerInset = .zero
        $0.setPretendard(with: .body2, text: Constant.contentPlaceholder)
        $0.textColor = .gray500
        $0.backgroundColor = .clear
    }
    
    private lazy var imageView: UIImageView = .init().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    private lazy var deleteButton: UIButton = .init(configuration: .plain()).then {
        $0.configuration?.image = .btnRemovePhoto
        $0.isHidden = true
    }
    
    private let divideView: UIView = .init(backgroundColor: .gray100)
    
    private lazy var imageButton: UIButton = .init(configuration: .plain()).then {
        $0.configuration?.image = .icPhoto
    }
    
    private let countLabel: UILabel = .init().then {
        $0.attributedText = "0/500".pretendardString(with: .caption4)
        $0.textColor = .gray600
    }
    
    private lazy var postButton: UIButton = .init(configuration: .filled()).then {
        $0.configuration?.attributedTitle = "게시".pretendardString(with: .body3)
        $0.configuration?.baseBackgroundColor = .purple50
        $0.configuration?.baseForegroundColor = .wableWhite
        $0.layer.cornerRadius = 16
        $0.configuration?.contentInsets = .init(top: 6, leading: 14, bottom: 6, trailing: 14)
        $0.clipsToBounds = true
        $0.isEnabled = false
    }
    
    // MARK: - LifeCycle
    
    init(viewModel: WritePostViewModel) {
        self.viewModel = viewModel
        
        super.init(type: .page(type: .detail, title: "새로운 글"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
        setupDelegate()
        setupBinding()
    }
}

// MARK: - Setup Extension

private extension WritePostViewController {
    func setupView() {
        navigationController?.navigationBar.isHidden = true
        
        view.addSubviews(
            scrollView,
            imageButton,
            countLabel,
            postButton,
            divideView
        )
        
        scrollView.addSubviews(stackView, deleteButton)
        
        stackView.addArrangedSubviews(titleTextView, imageView, contentTextView)
    }
    
    func setupConstraint() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-48)
        }
        
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.width.equalTo(scrollView)
        }
        
        imageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.adjustedHeightEqualTo(253)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(imageView).offset(16)
            $0.trailing.equalTo(imageView).inset(16)
            $0.size.equalTo(44.adjustedWidth)
        }
        
        divideView.snp.makeConstraints {
            $0.bottom.equalTo(imageButton.snp.top).offset(-8)
            $0.horizontalEdges.equalToSuperview()
            $0.adjustedHeightEqualTo(2)
        }
        
        imageButton.snp.makeConstraints {
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-7.5)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(32.adjustedWidth)
        }
        
        countLabel.snp.makeConstraints {
            $0.centerY.equalTo(imageButton)
            $0.trailing.equalTo(postButton.snp.leading).offset(-16)
        }
        
        postButton.snp.makeConstraints {
            $0.centerY.equalTo(imageButton)
            $0.trailing.equalToSuperview().inset(16)
            $0.adjustedWidthEqualTo(53)
            $0.adjustedHeightEqualTo(33)
        }
    }
    
    func setupAction() {
        navigationView.backButton.removeTarget(nil, action: nil, for: .touchUpInside)
        navigationView.backButton.addTarget(self, action: #selector(popButtonDidTap), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonDidTap), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        deleteButton.addAction(UIAction(handler: { [weak self] _ in
            self?.imageView.image = nil
            self?.imageView.isHidden = true
            self?.deleteButton.isHidden = true
        }), for: .touchUpInside)
    }
    
    func setupDelegate() {
        titleTextView.delegate = self
        contentTextView.delegate = self
    }
    
    func setupBinding() {
        let input = WritePostViewModel.Input(
            postButtonDidTap: postButtonTapRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.postSuccess
            .sink { _ in
                let toast = ToastView(status: .complete, message: "게시물이 작성되었습니다")
                toast.show()
                self.navigationController?.popViewController(animated: true)
            }
            .store(in: cancelBag)
    }
}

// MARK: - Action Extension

private extension WritePostViewController {
    @objc func addButtonDidTap() {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .denied, .restricted:
            presentSettings()
        case .authorized, .limited:
            presentPhotoPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    status == .authorized ? self.presentPhotoPicker() : nil
                }
            }
        default:
            break
        }
    }
    
    @objc func postButtonDidTap() {
        guard let title = titleTextView.text else { return }
        
        let content = contentTextView.text == Constant.contentPlaceholder ? nil : contentTextView.text
        
        postButtonTapRelay.send((title: title, content: content, image: imageView.image))
        WableLogger.log("postButtonTapRelay 실행 완료", for: .debug)
    }
    
    @objc func popButtonDidTap() {
        if (contentTextView.text == Constant.contentPlaceholder || contentTextView.text == "")
            && (titleTextView.text == Constant.titlePlaceholder || titleTextView.text == "")
            && imageView.image == nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            let popup = WableSheetViewController(title: "작성중인 글에서 나가실건가요?\n작성하셨던 내용은 삭제돼요")
            
            popup.addActions(
                WableSheetAction(title: "취소", style: .gray),
                WableSheetAction(title: "나가기", style: .primary, handler: {
                    self.navigationController?.popViewController(animated: true)
                })
            )
            
            self.present(popup, animated: true)
        }
    }
}


// MARK: - Helper Extension

private extension WritePostViewController {
    private func updateCharacterCount() {
        let titleText = titleTextView.textColor == .gray700 ? "" : titleTextView.text
        let contentText = contentTextView.textColor == .gray500 ? "" : contentTextView.text
        
        let titleCount = titleText?.count ?? 0
        let contentCount = contentText?.count ?? 0
        let totalCount = titleCount + contentCount
        
        countLabel.text = "\(totalCount)/500"
        
        if titleCount > 250 {
            titleTextView.text = String(titleTextView.text.prefix(250))
            updateCharacterCount()
            return
        }
        
        let isEnabled = totalCount > 0 && totalCount <= 500 && titleTextView.text != Constant.titlePlaceholder && !titleTextView.text.isEmpty
        
        postButton.isEnabled = isEnabled
        postButton.configuration?.baseBackgroundColor = isEnabled ? .purple50 : .gray400
    }
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func presentSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        let alert = UIAlertController(
            title: "설정",
            message: "사진 권한이 없습니다.\n설정으로 이동해 권한 설정을 진행해주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        alert.addAction(UIAlertAction(title: "권한 설정하기", style: .default) { _ in
            UIApplication.shared.open(url)
        })
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension WritePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
            guard let image = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.isHidden = false
                self.deleteButton.isHidden = false
            }
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
// TODO: 리팩 시 개선 필요

extension WritePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let placeholder = textView == titleTextView ? Constant.titlePlaceholder : Constant.contentPlaceholder
        
        if textView.text == placeholder {
            textView.text = nil
            textView.textColor = .wableBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let placeholder = textView == titleTextView ? Constant.titlePlaceholder : Constant.contentPlaceholder
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholder
            textView.textColor = .gray500
            updateCharacterCount()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCount()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let isPlaceholder = textView == titleTextView || textView == contentTextView 
         
        if isPlaceholder {
            return true
        }
        
        let titleCount = titleTextView.textColor == .gray500 ? 0 : titleTextView.text.count
        let contentCount = contentTextView.textColor == .gray500 ? 0 : contentTextView.text.count
        let currentCount = textView == titleTextView ? titleCount : contentCount
        let otherCount = textView == titleTextView ? contentCount : titleCount
        
        guard let oldText = textView.text,
              let stringRange = Range(range, in: oldText)
        else {
            return true
        }
        
        let newTextCount = oldText.replacingCharacters(in: stringRange, with: text).count
        
        if textView == titleTextView && newTextCount > 250 {
            return false
        }
        
        return (newTextCount - currentCount) + otherCount + currentCount < 500
    }
}

// MARK: - Constant

extension WritePostViewController {
    enum Constant {
        static let titlePlaceholder: String = "자유롭게 이야기해요"
        static let contentPlaceholder: String = "지금 머릿속에 떠오른 생각들을 남겨보세요\n본문은 생략이 가능해요"
    }
}
