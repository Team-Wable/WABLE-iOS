//
//  FeedDetailViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/18/24.
//

import UIKit

import SnapKit

@frozen
enum FeedDetailSection: Int, CaseIterable {
    case feed
    case reply
}

final class FeedDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    let feedReplyDummy: [FeedDetailReplyDTO] = [FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "하암",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 11,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "T1"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "뭘봐",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 21,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "DRX"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "하암",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 11,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말시발발발발발발바랍라발바라왜안되는데",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "T1"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "뭘봐",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 21,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "DRX"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "하암",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 11,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "T1"),
                                                FeedDetailReplyDTO(commentID: 0,
                                                                   memberID: 0,
                                                                   memberProfileURL: "",
                                                                   memberNickname: "뭘봐",
                                                                   isGhost: false,
                                                                   memberGhost: 0,
                                                                   isLiked: false,
                                                                   commentLikedNumber: 21,
                                                                   commentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말",
                                                                   time: "2024-02-06 23:46:50",
                                                                   isDeleted: false,
                                                                   commentImageURL: "",
                                                                   memberFanTeam: "DRX")]
    
    var feedData: HomeFeedDTO? = nil
    // MARK: - UI Components
    
    private let feedDetailView = FeedDetailView()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        view = feedDetailView
        self.view.backgroundColor = .wableWhite
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPI()
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        setNavigationBar()
        dismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "게시글"
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
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
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
            textView.textColor = .placeholderText
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
            return feedReplyDummy.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = FeedDetailSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch sectionType {
        case .feed:
            let cell = feedDetailView.feedDetailTableView.dequeueReusableCell(withIdentifier: HomeFeedTableViewCell.identifier, for: indexPath) as? HomeFeedTableViewCell ?? HomeFeedTableViewCell()
            cell.selectionStyle = .none
            cell.seperateLineView.isHidden = false
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
            cell.bind(data: feedReplyDummy[indexPath.row])
            return cell
        }
    }
}
