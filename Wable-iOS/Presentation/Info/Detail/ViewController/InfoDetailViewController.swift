//
//  InfoDetailViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit
import SafariServices

import Kingfisher

final class InfoDetailViewController: UIViewController {
    
    struct Configuration {
        let navigationTitle: String
        let title: String
        let text: String
        let time: String
        let imageURLString: String?
        let isButtonHidden: Bool
    }
    
    // MARK: - Property
    
    private let configuration: Configuration
    private let rootView = InfoDetailView()
    
    // MARK: - Initializer

    init(configuration: Configuration) {
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAction()
        setupDelegate()
        setupNavigationBar()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension InfoDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - Private Method

private extension InfoDetailViewController {
    func setupView() {
        rootView.titleLabel.text = configuration.title
        rootView.timeLabel.text = configuration.time
        rootView.bodyLabel.text = configuration.text
        rootView.submitOpinionButtonContainer.isHidden = configuration.isButtonHidden
        
        guard let imageURLString = configuration.imageURLString else { return }
        rootView.imageView.isHidden = false
        rootView.imageView.kf.setImage(with: URL(string: imageURLString))
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        rootView.imageView.addGestureRecognizer(tapGesture)
        
        let submitOpinionAction = UIAction { [weak self] _ in
            guard let url = URL(string: StringLiterals.Info.submitOpinionURL) else { return }
            let safariViewController = SFSafariViewController(url: url)
            self?.present(safariViewController, animated: true)
        }
        
        rootView.submitOpinionButton.addAction(submitOpinionAction, for: .touchUpInside)
    }
    
    @objc
    func imageViewDidTap() {
        guard let image = rootView.imageView.image else { return }
        
        let imagePopupViewController = ImagePopupViewController(image: image)
        imagePopupViewController.modalPresentationStyle = .overCurrentContext
        imagePopupViewController.modalTransitionStyle = .crossDissolve
        present(imagePopupViewController, animated: true)
    }
    
    func setupDelegate() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupNavigationBar() {
        navigationItem.title = configuration.navigationTitle
        
        let backButton = UIBarButtonItem(
            image: .icBack.withTintColor(.white, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backButtonDidTap)
        )
        navigationItem.leftBarButtonItem = backButton
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableWhite,
            .font: UIFont.body1
        ]
    }
    
    @objc
    func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}
