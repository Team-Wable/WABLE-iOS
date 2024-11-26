//
//  InfoDetailViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit

import Kingfisher

final class InfoDetailViewController: UIViewController {
    
    enum DetailType {
        case news(NewsDTO)
        case notice
    }
    
    // MARK: - Property
    
    private let detailType: DetailType
    private let rootView = InfoDetailView()
    
    // MARK: - Initializer

    init(detailType: DetailType) {
        self.detailType = detailType
        
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
        switch detailType {
        case .news(let news):
            setupFor(news: news)
        case .notice:
            break
        }
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        rootView.imageView.addGestureRecognizer(tapGesture)
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
    
    func setupFor(news: NewsDTO) {
        rootView.titleLabel.text = news.title
        rootView.timeLabel.text = news.time
        rootView.bodyLabel.text = news.text
        
        guard let imageURLString = news.imageURLString else { return }
        rootView.imageView.isHidden = false
        rootView.imageView.kf.setImage(with: URL(string: imageURLString))
    }
    
    func setupNavigationBar() {
        navigationItem.title = detailType.title
        
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

extension InfoDetailViewController.DetailType {
    var title: String {
        switch self {
        case .news:
            return "뉴스"
        case .notice:
            return "공지사항"
        }
    }
}
