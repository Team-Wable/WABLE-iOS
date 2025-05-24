//
//  AnnouncementDetailViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit
import SafariServices

import Kingfisher

final class AnnouncementDetailViewController: UIViewController {
    
    // MARK: - AnnouncementType
    
    enum AnnouncementType {
        case news
        case notice
        
        fileprivate var navigationTitle: String {
            switch self {
            case .news:
                return "뉴스"
            case .notice:
                return "공지사항"
            }
        }
    }
    
    // MARK: - Property
    
    private let rootView = AnnouncementDetailView()
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAction()
        setupNavigationBar()
    }
    
    func configure(
        type: AnnouncementType,
        title: String,
        time: String,
        imageURL: URL?,
        bodyText: String
    ) {
        navigationTitleLabel.text = type.navigationTitle
        titleLabel.text = title
        timeLabel.text = time
        bodyTextView.text = bodyText
        
        submitButtonContainerView.isHidden = !(type == .notice)
        
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            switch result {
            case .success(_):
                self?.imageView.isHidden = false
            case .failure(_):
                self?.imageView.isHidden = true
            }
        }
    }
}

// MARK: - Setup Method

private extension AnnouncementDetailViewController {
    func setupAction() {
        navigationBackButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        imageView.addGestureRecognizer(tapGesture)
        
        submitButton.addTarget(self, action: #selector(submitButtonDidTap), for: .touchUpInside)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

// MARK: - Action Method

private extension AnnouncementDetailViewController {
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageViewDidTap() {
        guard let image = imageView.image else { return }
        
        let photoDetailViewController = PhotoDetailViewController(image: image)
        present(photoDetailViewController, animated: true)
    }
    
    @objc func submitButtonDidTap() {
        guard let url = URL(string: Constant.googleFormURLText) else { return }
        
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true)
    }
}

// MARK: - Computed Property

private extension AnnouncementDetailViewController {
    var navigationBackButton: UIButton { rootView.navigationBackButton }
    var navigationTitleLabel: UILabel { rootView.navigationTitleLabel }
    var titleLabel: UILabel { rootView.titleLabel }
    var timeLabel: UILabel { rootView.timeLabel }
    var imageView: UIImageView { rootView.imageView }
    var bodyTextView: UITextView { rootView.bodyTextView }
    var submitButtonContainerView: UIView { rootView.submitButtonContainerView }
    var submitButton: UIButton { rootView.submitButton }
}

// MARK: - Constant

private extension AnnouncementDetailViewController {
    enum Constant {
        static let googleFormURLText: String = "https://docs.google.com/forms/d/e/1FAIpQLSf3JlBkVRPaPFSreQHaEv-u5pqZWZzk7Y4Qll9lRP0htBZs-Q/viewform"
    }
}
