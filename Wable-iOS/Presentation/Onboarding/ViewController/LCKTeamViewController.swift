//
//  LCKTeamViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

final class LCKTeamViewController: NavigationViewController {

    // MARK: - Property

    private let lckYear: Int
    private var lckTeam = "LCK"

    var navigateToProfileRegister: ((OnboardingProfileInfo) -> Void)?

    // MARK: - UIComponent

    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Onboarding.teamSheetTitle.pretendardString(with: .head0)
        $0.textColor = .wableBlack
    }

    private let descriptionLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Onboarding.teamSheetMessage.pretendardString(with: .body2)
        $0.textColor = .gray600
        $0.numberOfLines = 2
    }

    private lazy var teamCollectionView: TeamCollectionView = TeamCollectionView { [weak self] selectedTeam in
        guard let self else { return }

        self.lckTeam = selectedTeam
        self.nextButton.updateStyle(.primary)
        self.nextButton.isUserInteractionEnabled = true
    }

    private lazy var skipButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.attributedTitle = StringLiterals.Onboarding.teamEmptyButtonTitle.pretendardString(with: .body2)
        $0.configuration?.baseForegroundColor = .gray600
    }

    private lazy var nextButton: WableButton = WableButton(style: .gray).then {
        $0.configuration?.attributedTitle = "다음으로".pretendardString(with: .head2)
        $0.isUserInteractionEnabled = false
    }

    // MARK: - Life Cycle

    init(lckYear: Int) {
        self.lckYear = lckYear

        super.init(type: .flow)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        setupAction()
    }
}

// MARK: - Setup Method

private extension LCKTeamViewController {
    func setupConstraints() {
        view.addSubviews(
            titleLabel,
            descriptionLabel,
            teamCollectionView,
            skipButton,
            nextButton
        )
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
        }

        teamCollectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(368)
        }

        skipButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(48)
            $0.adjustedHeightEqualTo(48)
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        }

        nextButton.snp.makeConstraints {
            $0.adjustedHeightEqualTo(56)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(64)
        }
    }

    func setupAction() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        skipButton.addTarget(self, action: #selector(skipButtonDidTap), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension LCKTeamViewController {
    @objc func skipButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickDetourTeamSignup)

        var profileInfo = OnboardingProfileInfo()
        profileInfo.lckYear = lckYear
        profileInfo.lckTeam = "LCK"

        navigateToProfileRegister?(profileInfo)
    }

    @objc func nextButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickNextTeamSignup)

        var profileInfo = OnboardingProfileInfo()
        profileInfo.lckYear = lckYear
        profileInfo.lckTeam = lckTeam

        navigateToProfileRegister?(profileInfo)
    }
}
