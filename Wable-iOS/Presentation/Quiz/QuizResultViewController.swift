//
//  QuizResultViewController.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/22/25.
//


import UIKit

import SnapKit
import Then

public final class QuizResultViewController: UIViewController {
    
    // MARK: Property
    
    private let viewModel: QuizResultViewModel
    
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
    
    private let xpView: QuizRewardView = QuizRewardView(state: .xp(isCorrect: false))
    
    private let topView: QuizRewardView = QuizRewardView(state: .top(percent: 0))
    
    private let speedView: QuizRewardView = QuizRewardView(state: .speed(speed: 0))
    
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
        }
        
        xpView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
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
        
    }
    
    func setupAction() {
        rewardButton.addTarget(self, action: #selector(rewardButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension QuizResultViewController {
    @objc func rewardButtonDidTap() {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        let tabBarController = keyWindow?.rootViewController as? TabBarController

        if let currentNavController = tabBarController?.selectedViewController as? UINavigationController {
            currentNavController.popToRootViewController(animated: false)
            tabBarController?.selectedIndex = 2
        }
        
        // TODO: 유저디폴트에서 상태 변환

        dismiss(animated: true)
    }
}


// MARK: - Helper Method

private extension QuizResultViewController {
    func configureView(isCorrect: Bool) {
        answerImageView.image = isCorrect ? .imgQuizSuccess : .imgQuizFail
        titleLabel.text = isCorrect ? Constant.correctTitle : Constant.incorrectTitle
        descriptionLabel.text = isCorrect ? Constant.correctDescription : Constant.incorrectDescription
    }
}

// MARK: - Constant

private extension QuizResultViewController {
    private enum Constant {
        static let correctTitle: String = "걸어다니는 LCK 백과사전"
        static let correctDescription: String = "정답을 맞추셨어요. 대단해요!"
        static let incorrectTitle: String = "LCK의 평범한 시청자!"
        static let incorrectDescription: String = "정답은 틀렸지만, 좋은 시도였어요!\n다음 기회를 노려봐요"
    }
}
