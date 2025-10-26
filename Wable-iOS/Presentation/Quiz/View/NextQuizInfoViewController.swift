//
//  NextQuizInfoViewController.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/21/25.
//

import SafariServices
import UIKit
import Combine

import SnapKit
import Then


final class NextQuizInfoViewController: NavigationViewController {
    
    // MARK: Property

    private let viewModel: NextQuizInfoViewModel
    private let cancelBag = CancelBag()
    
    // MARK: - UIComponent

    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()
    private let refreshControl = UIRefreshControl()

    private let safeAreaBackgroundView: UIView = UIView(backgroundColor: .wableBlack)
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Quiz.nextQuizTitle.pretendardString(with: .head0)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.textColor = .wableBlack
    }
    
    private let backgroundImage: UIImageView = UIImageView(image: .imgQuizTime).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let remainTimeLabel: UILabel = UILabel().then {
        $0.attributedText = "00 : 00".pricedownString(with: .black)
        $0.textColor = .wableBlack
        $0.textAlignment = .center
    }
    
    private let feedbackButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.attributedTitle = StringLiterals.Quiz.feedbackTitle
            .pretendardString(with: .body3)
            .highlight(textColor: .sky50, to: "→")
        $0.configuration?.baseForegroundColor = .wableWhite
        $0.backgroundColor = .wableBlack
        $0.layer.cornerRadius = 12.adjustedHeight
    }
    
    // MARK: - LifeCycle

    init(type: NavigationType, viewModel: NextQuizInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBinding()
        setupAction()
    }
}

private extension NextQuizInfoViewController {
    func setupView() {
        navigationController?.navigationBar.isHidden = true
        scrollView.refreshControl = refreshControl

        view.addSubviews(scrollView, safeAreaBackgroundView, feedbackButton)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            titleLabel,
            backgroundImage,
            remainTimeLabel
        )

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        safeAreaBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(75)
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        backgroundImage.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.6)
        }

        remainTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(backgroundImage).offset(-13)
            make.centerX.equalToSuperview()
        }

        feedbackButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.adjustedHeightEqualTo(48)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func setupBinding() {
        let output = viewModel.transform(
            input: .init(
                refreshDidTrigger: refreshControl
                    .publisher(for: .valueChanged)
                    .eraseToAnyPublisher()
            ),
            cancelBag: cancelBag
        )

        output.remainTime
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, timeString in
                owner.remainTimeLabel.attributedText = timeString.pricedownString(with: .black)
                owner.refreshControl.endRefreshing()
            }
            .store(in: cancelBag)
    }
    
    func setupAction() {
        feedbackButton.addTarget(self, action: #selector(feedbackButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Action Method

private extension NextQuizInfoViewController {
    @objc func feedbackButtonDidTap() {
        guard let url = URL(string: StringLiterals.URL.feedbackForm) else { return }
        let safariController = SFSafariViewController(url: url)

        self.present(safariController, animated: true)
    }
}
