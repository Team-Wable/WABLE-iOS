//
//  LoadingViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/14/25.
//

import UIKit

import Lottie
import SnapKit
import Then

final class LoadingViewController: UIViewController {
    
    // MARK: - UIComponent

    private let loadingAnimationView = LottieAnimationView(
        name: LottieType.loading.rawValue
    ).then{
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
    }

    private lazy var messageLabel = UILabel().then {
        $0.attributedText = Self.messages.randomElement()?.pretendardString(with: .head1)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    // MARK: - Property

    private let loadingDuration: TimeInterval = 1.6
    
    // MARK: - Initializer

    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startAnimationAndDismiss()
    }
    
    private func startAnimationAndDismiss() {
        loadingAnimationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDuration) {
            self.loadingAnimationView.pause()
            self.dismiss(animated: true)
        }
    }
}

// MARK: - Setup Method

private extension LoadingViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            loadingAnimationView,
            messageLabel
        )
    }
    
    func setupConstraint() {
        loadingAnimationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(252)
            make.centerX.equalToSuperview()
            make.adjustedWidthEqualTo(160)
            make.height.equalTo(loadingAnimationView.snp.width)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(loadingAnimationView.snp.bottom).offset(36)
            make.horizontalEdges.equalToSuperview().inset(30)
        }
    }
}

// MARK: - Messages

private extension LoadingViewController {
    static let messages: [String]  = [
        "경기 보고 어디서 모여?\n와블에서",
        "와블와블",
        "팬으로서 저의가 해야 할 건\n끊임없는 응원이에요",
        "우리는 선수와 팀을 대표하는 얼굴이에요",
        "선수들을 응원하되 스포츠의 시각으로\n바라봐주세요",
        "온화함을 해치는 글에 슬며시 투명도를\n눌러주세요",
        "이기면 함께 축하하고, 지면 다음에\n잘하면 된다고 격려해 주세요",
        "일부 팬의 행동으로 전체 팬을\n욕하지 말아주세요",
        "말하기 전에 항상\n다시 한번 생각하기 약속!",
        "숨어있는 롤잘알분들 나와주세요",
        "함께 경기 볼 사람들은 여기로 모여~",
        "유쾌하면서도 편안할 수 있는 공간\n함께 만들어 주실 거죠?",
        "'나는 와블해'라고 말할 수 있는\n커뮤니티가 되고 싶어요!",
        "와블은 온화한 LCK 팬들이\n모이는 공간을 지향해요",
        "와블이라는 이름은 새가 부르는 노래라는\n뜻을 가진 Warble에서 유래했어요",
        "경기 라이브로 챙겨 본 후, 하이라이트\n보고, BJ 경기 후기, 전문가 평가까지\n싹 찾아보는 사람 손~!",
        "와글와글"
    ]
}
