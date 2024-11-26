//
//  HomeLoadingView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 11/25/24.
//

import UIKit

import SnapKit
import Lottie

final class HomeLoadingView: UIView {
    
    // MARK: - Properties
    
    let loadingText = [
        "팬으로서 저희가 해야 할 건 끊임없는 응원이에요",
        "우리는 선수와 팀을 대표하는 얼굴이에요",
        "선수들을 응원하되 스포츠의 시각으로 바라봐주세요",
        "온화함을 해치는 글에 슬며시 투명도를 눌러주세요",
        "이기면 함께 축하하고, 지면 다음에 잘하면 된다고 격려해 주세요",
        "일부 팬의 행동으로 전체 팬을 욕하지 말아주세요",
        "말하기 전에 항상 다시 한번 생각하기 약속!",
        "숨어있는 롤잘알분들 나와주세요",
        "경기 라이브로 챙겨 본 후, 하이라이트 보고, BJ 경기 후기, 전문가 평가까지 싹 찾아보는 사람 손~!",
        "경기 보고 어디서 모여? 와블에서!",
        "함께 경기 볼 사람들은 여기로 모여~",
        "유쾌하면서도 편안할 수 있는 공간 함께 만들어 주실 거죠?",
        "‘나는 와블해’라고 말할 수 있는 커뮤니티가 되고 싶어요!",
        "와블은 온화한 LCK 팬들이 모이는 공간을 지향해요",
        "와블이라는 이름은 새가 부르는 노래라는 뜻을 가진 Warble에서 유래했어요",
        "와글와글",
        "와블와블"
    ]
    
    // MARK: - UI Components
    
    let lottieLoadingView: LottieAnimationView = {
        let lottieView = LottieAnimationView(name: "wable_loading")
        lottieView.contentMode = .scaleAspectFill
        return lottieView
    }()
    
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.font = .head1
        label.textColor = .wableBlack
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setHierarchy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setUI() {
        self.backgroundColor = .white
    }
    
    private func setHierarchy() {
        addSubviews(lottieLoadingView, loadingLabel)
    }
    
    private func setLayout() {
        lottieLoadingView.snp.makeConstraints {
            $0.size.equalTo(160.adjusted)
            $0.top.equalTo(safeAreaLayoutGuide).inset(210.adjustedH)
            $0.centerX.equalToSuperview()
        }
        
        loadingLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.top.equalTo(lottieLoadingView.snp.bottom).offset(35.adjusted)
        }
    }
}
