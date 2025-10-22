//
//  QuizViewController.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/21/25.
//

import UIKit

import SnapKit
import Then

final class QuizViewController: NavigationViewController {
    
    // MARK: - UIComponent
    
    private let quizImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let descriptionLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
        $0.textAlignment = .center
        $0.attributedText = " ".pretendardString(with: .head1)
    }
    
    private lazy var correctButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.background.backgroundColor = .clear
        $0.setImage(.btnCorrectDefault, for: .normal)
        $0.setImage(.btnCorrectSelected, for: .selected)
    }

    private lazy var incorrectButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.background.backgroundColor = .clear
        $0.setImage(.btnIncorrectDefault, for: .normal)
        $0.setImage(.btnIncorrectSelected, for: .selected)
    }
    
    private lazy var submitButton: WableButton = WableButton(style: .gray).then {
        $0.configuration?.attributedTitle = "제출하기".pretendardString(with: .head2)
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - Life Cycle

    override init(type: NavigationType) {
        super.init(type: type)
        
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAction()
    }
}

// MARK: - Setup Method

private extension QuizViewController {
    func setupView() {
        view.addSubviews(
            quizImageView,
            descriptionLabel,
            correctButton,
            incorrectButton,
            submitButton
        )
        
        quizImageView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.adjustedHeightEqualTo(246)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(quizImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        submitButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(64)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.adjustedHeightEqualTo(56)
        }
        
        correctButton.snp.makeConstraints { make in
            make.bottom.equalTo(submitButton.snp.top).offset(-36)
            make.trailing.equalTo(view.snp.centerX).offset(-7)
            make.size.equalTo(144)
        }
        
        incorrectButton.snp.makeConstraints { make in
            make.bottom.equalTo(correctButton)
            make.leading.equalTo(view.snp.centerX).offset(7)
            make.size.equalTo(144)
        }
    }

    func setupAction() {
        correctButton.addTarget(self, action: #selector(correctButtonDidTap), for: .touchUpInside)
        incorrectButton.addTarget(self, action: #selector(incorrectButtonDidTap), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension QuizViewController {
    @objc func correctButtonDidTap() {
        enableSubmitButton()
        updateCorrectState(true)
    }
    
    @objc func incorrectButtonDidTap() {
        enableSubmitButton()
        updateCorrectState(false)
    }
    
    @objc func submitButtonDidTap() {
        let state = correctButton.isSelected
        let viewController = QuizResultViewController(viewModel: QuizResultViewModel(answer: state, totalTime: 0))
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true)
    }
    
    func enableSubmitButton() {
        submitButton.updateStyle(.primary)
        submitButton.isUserInteractionEnabled = true
    }
    
    func updateCorrectState(_ isCorrect: Bool) {
        correctButton.isSelected = isCorrect
        incorrectButton.isSelected = !isCorrect
    }
}


