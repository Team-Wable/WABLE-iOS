//
//  SplashViewController.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

import Lottie

final class SplashViewController: UIViewController {
    
    private lazy var lottieAnimationView: LottieAnimationView = {
        let animation = LottieAnimationView(name: "wable_splash")
        animation.contentMode = .scaleAspectFill
        animation.loopMode = .playOnce
        animation.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { finished in
            if finished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    animation.stop()
                }
            }
        }
        return animation
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
    }
    
    private func setUI() {
        view.backgroundColor = .white
    }
    
    private func setLayout() {
        self.view.addSubview(lottieAnimationView)
        lottieAnimationView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
