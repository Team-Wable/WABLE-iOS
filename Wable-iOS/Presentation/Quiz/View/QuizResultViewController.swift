//
//  QuizResultViewController.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/22/25.
//


import UIKit
import Combine

import SnapKit
import Then

public final class QuizResultViewController: UIViewController {
    
    // MARK: Property

    private let viewModel: QuizResultViewModel
    private let cancelBag = CancelBag()
    
    // MARK: - UIComponent
    
    private let answerImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .head0)
        $0.textColor = .wableBlack
        $0.textAlignment = .center
    }
    
    private let descriptionLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .head1)
        $0.textColor = .wableBlack
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let xpView: QuizRewardView = QuizRewardView(state: .xp)
    
    private let topView: QuizRewardView = QuizRewardView(state: .top)
    
    private let speedView: QuizRewardView = QuizRewardView(state: .speed)
    
    private let rewardButton: WableButton = WableButton(style: .primary).then {
        $0.configuration?.attributedTitle = "XP 받기".pretendardString(with: .head2)
    }
    
    // MARK: - LifeCycle

    init(viewModel: QuizResultViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBinding()
        setupAction()
    }
}

// MARK: - Setup Method

private extension QuizResultViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            answerImageView,
            titleLabel,
            descriptionLabel,
            xpView,
            topView,
            speedView,
            rewardButton
        )
        
        answerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(117)
            make.adjustedWidthEqualTo(204)
            make.adjustedHeightEqualTo(236)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(answerImageView.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        xpView.snp.makeConstraints { make in
            make.bottom.equalTo(rewardButton.snp.top).offset(-82)
            make.leading.equalToSuperview().offset(36)
        }
        
        topView.snp.makeConstraints { make in
            make.top.equalTo(xpView)
            make.leading.equalTo(xpView.snp.trailing).offset(6)
        }
        
        speedView.snp.makeConstraints { make in
            make.top.equalTo(xpView)
            make.leading.equalTo(topView.snp.trailing).offset(6)
        }
        
        rewardButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(64)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.adjustedHeightEqualTo(56)
        }
    }
    
    func setupBinding() {
        let output = viewModel.transform(input: .init(), cancelBag: cancelBag)

        output.updateQuizResult
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.configureView(isCorrect: result.result.isCorrect)
                owner.speedView.configureView(speed: result.speed)
                owner.topView.configureView(topPercent: result.result.topPercent)
                owner.xpView.configureView(isCorrect: result.result.isCorrect)
            })
            .store(in: cancelBag)

        output.error
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, error in
                let toast = WableSheetViewController(
                    title: StringLiterals.Quiz.rewardErrorTitle,
                    message: "\(error.localizedDescription)\n\(StringLiterals.Quiz.loadingErrorMessage)"
                )

                toast.addAction(.init(title: "확인", style: .primary))
                owner.present(toast, animated: true)
            }
            .store(in: cancelBag)
    }
    
    func setupAction() {
        rewardButton.addTarget(self, action: #selector(rewardButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension QuizResultViewController {
    @objc func rewardButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickGetXP)
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        let tabBarController = keyWindow?.rootViewController as? TabBarController

        if let currentNavController = tabBarController?.selectedViewController as? UINavigationController {
            currentNavController.popToRootViewController(animated: false)
            tabBarController?.selectedIndex = 2
        }

        dismiss(animated: true)
    }
}


// MARK: - Helper Method

private extension QuizResultViewController {
    func configureView(isCorrect: Bool) {
        answerImageView.image = isCorrect ? .imgQuizSuccess : .imgQuizFail
        titleLabel.text = isCorrect ? StringLiterals.Quiz.correctTitle : StringLiterals.Quiz.incorrectTitle
        descriptionLabel.text = isCorrect ?
        StringLiterals.Quiz.correctDescription :
        StringLiterals.Quiz.incorrectDescription
    }
}
