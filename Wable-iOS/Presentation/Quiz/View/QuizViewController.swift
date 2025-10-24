//
//  QuizViewController.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/21/25.
//

import UIKit
import Combine

import Kingfisher
import SnapKit
import Then

final class QuizViewController: NavigationViewController {

    // MARK: - Property

    private let viewModel: QuizViewModel
    private let cancelBag = CancelBag()

    // MARK: - UIComponent
    
    private let quizImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let descriptionLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
        $0.attributedText = " ".pretendardString(with: .head2)
        $0.textAlignment = .center
        $0.numberOfLines = 4
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

    init(type: NavigationType, viewModel: QuizViewModel) {
        self.viewModel = viewModel
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
        setupBinding()
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
    }

    func setupBinding() {
        let output = viewModel.transform(
            input: .init(
                submitButtonDidTap: submitButton
                    .publisher(for: .touchUpInside)
                    .compactMap { [weak self] in self?.correctButton.isSelected }
                    .eraseToAnyPublisher()
            ),
            cancelBag: cancelBag
        )

        output.quizInfo
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, quiz in
                if let url = URL(string: quiz.imageURL) {
                    owner.quizImageView.kf.setImage(with: url)
                }
                
                owner.descriptionLabel.text = quiz.text
            }
            .store(in: cancelBag)

        output.answerInfo
            .withLatestFrom(output.quizInfo) { answerInfo, quiz in
                (quiz: quiz, answerInfo: answerInfo)
            }
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, data in
                let viewModel = QuizResultViewModel(
                    quizInfo: (
                        id: data.quiz.id,
                        userAnswer: data.answerInfo.answer,
                        totalTime: data.answerInfo.totalTime
                    )
                )
                let resultViewController = QuizResultViewController(viewModel: viewModel)
                resultViewController.modalPresentationStyle = .fullScreen
                owner.present(resultViewController, animated: true)
            }
            .store(in: cancelBag)

        output.error
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, error in
                let toast = WableSheetViewController(
                    title: StringLiterals.Quiz.loadingErrorTitle,
                    message: "\(error.localizedDescription)\n\(StringLiterals.Quiz.loadingErrorMessage)"
                )
                toast.addAction(.init(title: "확인", style: .primary, handler: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }))
                
                owner.present(toast, animated: true)
            }
            .store(in: cancelBag)
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
    
    func enableSubmitButton() {
        submitButton.updateStyle(.primary)
        submitButton.isUserInteractionEnabled = true
    }
    
    func updateCorrectState(_ isCorrect: Bool) {
        correctButton.isSelected = isCorrect
        incorrectButton.isSelected = !isCorrect
    }
}


