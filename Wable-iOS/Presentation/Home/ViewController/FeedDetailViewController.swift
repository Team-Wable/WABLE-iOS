//
//  FeedDetailViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/18/24.
//

import Combine
import SafariServices
import UIKit

import SnapKit

@frozen
enum FeedDetailSection: Int, CaseIterable {
    case feed
    case reply
}

final class FeedDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: FeedDetailViewModel
    private var cancelBag = CancelBag()
    
    private lazy var postButtonTapped =
    self.feedDetailView.bottomWriteView.uploadButton.publisher(for: .touchUpInside).map { _ in
        return (WriteReplyRequestDTO(
            commentText: self.feedDetailView.bottomWriteView.writeTextView.text,
            notificationTriggerType: "comment"), self.contentId)
    }.eraseToAnyPublisher()
    
    var contentId: Int = 0
    var commentId: Int = 0
    var memberId: Int = 0
    var postMemberId: Int = 0
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    var ghostReason: String = ""
    var postViewHeight = 0
    var userNickName: String = ""
    var userProfileURL: String = StringLiterals.Network.baseImageURL
    var contentText: String = ""
    var reportTargetNickname: String = ""
    var relateText: String = ""
    let warnUserURL = URL(string: StringLiterals.Network.warnUserGoogleFormURL)
    private let placeholder = StringLiterals.Home.placeholder
    
    let refreshControl = UIRefreshControl()
    
    var feedData: HomeFeedDTO? = nil
    
    // MARK: - UI Components
    
    private let feedDetailView = FeedDetailView()
    private let divideLine = UIView().makeDivisionLine()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        view = feedDetailView
        self.view.backgroundColor = .wableWhite
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        setNavigationBar()
        dismissKeyboard()
        setRefreshControl()
    }
    
    init(viewModel: FeedDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "게시글"
        
        getAPI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Extensions

extension FeedDetailViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        feedDetailView.feedDetailTableView.rowHeight = UITableView.automaticDimension
        feedDetailView.feedDetailTableView.estimatedRowHeight = 100
        navigationController?.navigationBar.barTintColor = .wableWhite
    }
    
    private func setHierarchy() {
        if let navigationBar = navigationController?.navigationBar {
               navigationBar.addSubview(divideLine)
            }
    }
    
    private func setLayout() {
        divideLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func setDelegate() {
        feedDetailView.feedDetailTableView.delegate = self
        feedDetailView.feedDetailTableView.dataSource = self
        feedDetailView.bottomWriteView.writeTextView.delegate = self
    }
    
    private func setNavigationBar() {
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.wableBlack,
            NSAttributedString.Key.font: UIFont.body1,
        ]
        
        let backButtonImage = ImageLiterals.Icon.icBack.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonDidTapped))
        navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
    private func setRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        feedDetailView.feedDetailTableView.refreshControl = self.refreshControl
    }
    
    @objc
    private func didPullToRefresh() {
        print("didPullToRefresh")
        DispatchQueue.main.async {
            self.getAPI()
        }
        self.perform(#selector(finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    private func backButtonDidTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    
    func getFeedData(data: HomeFeedDTO) {
        self.feedData = data
    }
    
    @objc
    private func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    
    
}

// MARK: - Network

extension FeedDetailViewController {
    private func getAPI() {
        let input = FeedDetailViewModel.Input(viewUpdate: Just((contentId)).eraseToAnyPublisher(),
                                              likeButtonTapped: nil,
                                              tableViewUpdata: Just((contentId)).eraseToAnyPublisher(),
                                              commentLikeButtonTapped: nil,
                                              postButtonTapped: postButtonTapped)
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.getPostData
            .receive(on: RunLoop.main)
            .sink { data in
                self.postMemberId = data.memberId
//                self.feedData = data
                self.feedDetailView.feedDetailTableView.reloadData()
//                self.perform(#selector(self.finishedRefreshing), with: nil, afterDelay: 0.1)
            }
            .store(in: self.cancelBag)
        
        output.getPostReplyData
            .receive(on: RunLoop.main)
            .sink { data in
                self.feedDetailView.feedDetailTableView.reloadData()
            }
            .store(in: self.cancelBag)
        
        output.postReplyCompleted
            .receive(on: RunLoop.main)
            .sink { data in
                if data == 0 {
                    self.viewModel.cursor = -1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.didPullToRefresh()
                        
                        self.feedDetailView.bottomWriteView.writeTextView.text = ""
                        self.feedDetailView.bottomWriteView.writeTextView.textColor = .gray700
                        self.feedDetailView.bottomWriteView.writeTextView.text = (self.feedData?.memberNickname ?? "") + self.placeholder
                        self.feedDetailView.bottomWriteView.writeTextView.textContainerInset = UIEdgeInsets(top: 10.adjusted,
                                                                                                            left: 10.adjusted,
                                                                                                            bottom: 10.adjusted,
                                                                                                            right: 10.adjusted)
                        
                        UIView.animate(withDuration: 0.3) {
                            self.feedDetailView.feedDetailTableView.contentOffset.y = 0
                        }
                    }
                }
            }
            .store(in: cancelBag)
        
//        output.clickedButtonState
//            .sink { [weak self] index in
//                guard let self = self else { return }
//                let radioSelectedButtonImage = ImageLiterals.TransparencyInfo.btnRadioSelected
//                let radioButtonImage = ImageLiterals.TransparencyInfo.btnRadio
//                self.transparentReasonView.warnLabel.isHidden = true
//                
//                switch index {
//                case 1:
//                    self.transparentReasonView.firstReasonView.radioButton.setImage(radioSelectedButtonImage, for: .normal)
//                    self.transparentReasonView.secondReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.thirdReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fourthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fifthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.sixthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    ghostReason = self.transparentReasonView.firstReasonView.radioButton.currentTitle ?? ""
//                case 2:
//                    self.transparentReasonView.firstReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.secondReasonView.radioButton.setImage(radioSelectedButtonImage, for: .normal)
//                    self.transparentReasonView.thirdReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fourthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fifthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.sixthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    ghostReason = self.transparentReasonView.secondReasonView.radioButton.currentTitle ?? ""
//                case 3:
//                    self.transparentReasonView.firstReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.secondReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.thirdReasonView.radioButton.setImage(radioSelectedButtonImage, for: .normal)
//                    self.transparentReasonView.fourthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fifthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.sixthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    ghostReason = self.transparentReasonView.thirdReasonView.radioButton.currentTitle ?? ""
//                case 4:
//                    self.transparentReasonView.firstReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.secondReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.thirdReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fourthReasonView.radioButton.setImage(radioSelectedButtonImage, for: .normal)
//                    self.transparentReasonView.fifthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.sixthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    ghostReason = self.transparentReasonView.fourthReasonView.radioButton.currentTitle ?? ""
//                case 5:
//                    self.transparentReasonView.firstReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.secondReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.thirdReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fourthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fifthReasonView.radioButton.setImage(radioSelectedButtonImage, for: .normal)
//                    self.transparentReasonView.sixthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    ghostReason = self.transparentReasonView.fifthReasonView.radioButton.currentTitle ?? ""
//                case 6:
//                    self.transparentReasonView.firstReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.secondReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.thirdReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fourthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.fifthReasonView.radioButton.setImage(radioButtonImage, for: .normal)
//                    self.transparentReasonView.sixthReasonView.radioButton.setImage(radioSelectedButtonImage, for: .normal)
//                    ghostReason = self.transparentReasonView.sixthReasonView.radioButton.currentTitle ?? ""
//                default:
//                    break
//                }
//            }
//            .store(in: self.cancelBag)
    }
    
    @objc
    func finishedRefreshing() {
        refreshControl.endRefreshing()
    }
}

// MARK: - TextView Delegate

extension FeedDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .gray700 else { return }
        textView.textColor = .wableBlack
        textView.text = nil
        print("textViewDidBeginEditing")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height > 86 {
            textView.isScrollEnabled = true
            return
        } else {
            //                textView.isScrollEnabled = false
            textView.isScrollEnabled = true
            
            // 레이아웃 중 height 수정
            textView.snp.remakeConstraints {
                $0.height.equalTo(estimatedSize)
                $0.leading.equalToSuperview().inset(16.adjusted)
                $0.trailing.equalTo(feedDetailView.bottomWriteView.uploadButton.snp.leading).offset(-6.adjusted)
                $0.centerY.equalToSuperview()
            }
            
            feedDetailView.bottomWriteView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                $0.height.equalTo(estimatedSize.height + 20)
            }
        }
        
        if (textView.text.count != 0) {
            feedDetailView.bottomWriteView.uploadButton.isEnabled = true
        } else {
            feedDetailView.bottomWriteView.uploadButton.isEnabled = false
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        
        if textView.text.isEmpty {
            textView.text = (feedData?.memberNickname ?? String()) + StringLiterals.Home.placeholder
            textView.textColor = .gray700
            feedDetailView.bottomWriteView.uploadButton.isEnabled = false
        }
    }
}

// MARK: - TableView Delegate, DataSource

extension FeedDetailViewController: UITableViewDelegate {}

extension FeedDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = FeedDetailSection(rawValue: section) else { return 0 }
        switch sectionType {
        case .feed:
            return 1
        case .reply:
            return viewModel.feedReplyDatas.count
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == feedDetailView.feedDetailTableView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height) {
                let lastCommentID = viewModel.feedReplyDatas.last?.commentId ?? -1
                viewModel.cursor = lastCommentID
//                self.didPullToRefresh()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = FeedDetailSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch sectionType {
        case .feed:
            let cell = feedDetailView.feedDetailTableView.dequeueReusableCell(withIdentifier: HomeFeedTableViewCell.identifier, for: indexPath) as? HomeFeedTableViewCell ?? HomeFeedTableViewCell()
            cell.selectionStyle = .none
            cell.seperateLineView.isHidden = false
            cell.divideLine.isHidden = true
            cell.bind(data: feedData ?? HomeFeedDTO(memberID: 0,
                                                    memberProfileURL: "",
                                                    memberNickname: "다시하세요",
                                                    contentID: 0, contentTitle: "contentTitle",
                                                    contentText: "",
                                                    time: "다시해",
                                                    isGhost: false,
                                                    memberGhost: 0,
                                                    isLiked: true,
                                                    likedNumber: 5,
                                                    commentNumber: 2,
                                                    isDeleted: false,
                                                    contentImageURL: "",
                                                    memberFanTeam: "T1"))
            return cell
        case .reply:
            let cell = feedDetailView.feedDetailTableView.dequeueReusableCell(withIdentifier: FeedDetailTableViewCell.identifier, for: indexPath) as? FeedDetailTableViewCell ?? FeedDetailTableViewCell()
            cell.selectionStyle = .none
            cell.bind(data: viewModel.feedReplyDatas[indexPath.row])
            return cell
        }
    }
}
