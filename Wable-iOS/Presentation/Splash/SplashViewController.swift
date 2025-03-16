//
//  SplashViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/17/25.
//


import UIKit

import Lottie

final class SplashViewController: UIViewController {
    
    // MARK: - UIComponent
    
    private lazy var animationView: LottieAnimationView = LottieAnimationView(name: "wable_splash").then { view in
        view.contentMode = .scaleAspectFill
        view.loopMode = .playOnce
        view.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce, completion: {
            $0 ? DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                view.stop()
            } : nil
        })
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
    }
}

// MARK: - Private Extension

private extension SplashViewController {
    
    // MARK: - Setup

    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(animationView)
    }
    
    func setupConstraint() {
        animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
