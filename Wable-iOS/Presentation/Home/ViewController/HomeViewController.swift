//
//  HomeViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    let dummyData: [HomeFeedDTO] = [HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "냐옹",
                                                        contentID: 1,
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!)여기서끝인줄 알았다면 아주 만만의 콩떡이시다 나는 여기서 더더더더덛 긴 글을 한번 써볼건데 내 생각으로는 안될 것 같다는 느낌느낌.... 아니 얘는 또 잘 되자나.... ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 10,
                                                        commentNumber: 22,
                                                        isDeleted: false,
                                                        contentImageURL: "",
                                                        memberFanTeam: "DRX"),
                                        HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "먀옹",
                                                        contentID: 1,
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 9,
                                                        commentNumber: 8,
                                                        isDeleted: false,
                                                        contentImageURL: "",
                                                        memberFanTeam: "T1"),
                                        HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "뭐임마",
                                                        contentID: 1,
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) 어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) 어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 4,
                                                        commentNumber: 93,
                                                        isDeleted: false,
                                                        contentImageURL: nil,
                                                        memberFanTeam: "GEN"),
                                        HomeFeedDTO(memberID: 0,
                                                        memberProfileURL: "",
                                                        memberNickname: "냐옹",
                                                        contentID: 1,
                                                        contentText: "어떤 순간에도 너를 찾을 수 있게 반대가 끌리는 천만번째 이유를 내일의 우리는 알지도 몰라 오늘따라 왠지 말이 꼬여 성을 빼고 부르는 건 아직 어색해 (지훈아..!) ",
                                                        time: "2024-01-10 11:47:18",
                                                        isGhost: false,
                                                        memberGhost: 0,
                                                        isLiked: false,
                                                        likedNumber: 10,
                                                        commentNumber: 22,
                                                        isDeleted: false,
                                                        contentImageURL: "",
                                                        memberFanTeam: "DRX")
                                        
    ]
    
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var writeButtonDidTapped = self.homeView.writeFeedButton.publisher(for: .touchUpInside).map { _ in }.eraseToAnyPublisher()
    
    // MARK: - UI Components
    
    private let homeView = HomeView()
    private var ghostPopupView: WablePopupView? = nil
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        self.view = homeView
    }
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setHierarchy()
        setLayout()
        setDelegate()
        setRefreshControl()

        bindViewModel()
    }
}

// MARK: - Extensions

extension HomeViewController {
    private func setUI() {
        self.view.backgroundColor = .wableWhite
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setHierarchy() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setDelegate() {
        homeView.feedTableView.dataSource = self
        homeView.feedTableView.delegate = self
    }
    
    private func bindViewModel() {
        
        viewModel.pushViewController
            .sink { [weak self] index in
                self?.navigationController?.isNavigationBarHidden = false
                let feedDetailViewController = FeedDetailViewController()
                feedDetailViewController.hidesBottomBarWhenPushed = true
                
                if let data = self?.dummyData[index] {
                    feedDetailViewController.getFeedData(data: data)
                }
                
                self?.navigationController?.pushViewController(feedDetailViewController, animated: true)
            }
            .store(in: &cancellables)
        
        writeButtonDidTapped
                .sink { [weak self] in
                    self?.viewModel.pushToWriteViewControllr.send()
                }
                .store(in: &cancellables)
        
        viewModel.pushToWriteViewControllr
            .sink { [weak self] in
                let writeViewController = WriteViewController(viewModel: WriteViewModel())
                writeViewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(writeViewController, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func showGhostPopupView() {
        self.ghostPopupView = WablePopupView(popupTitle: StringLiterals.Home.ghostPopupTitle,
                                             popupContent: "",
                                             leftButtonTitle: StringLiterals.Home.ghostPopupUndo,
                                             rightButtonTitle: StringLiterals.Home.ghostPopupDo)
        
        if let popupView = self.ghostPopupView {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                window.addSubviews(popupView)
            }
            
            popupView.delegate = self
            
            popupView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    private func setRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        homeView.feedTableView.refreshControl = self.refreshControl
    }
    
    @objc
    private func didPullToRefresh() {
        print("리프레쉬컨트롤 작동동")
        self.perform(#selector(finishedRefreshing), with: nil, afterDelay: 0.1)
    }
    
    @objc
    private func finishedRefreshing() {
        self.refreshControl.endRefreshing()
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeView.feedTableView.dequeueReusableCell(withIdentifier: HomeFeedTableViewCell.identifier, for: indexPath) as? HomeFeedTableViewCell ?? HomeFeedTableViewCell()
        cell.selectionStyle = .none
        cell.bind(data: dummyData[indexPath.row])
        
        cell.bottomView.commentButtonTapped = { [weak self] in
            self?.viewModel.commentButtonTapped.send(indexPath.row)
        }
        
        cell.bottomView.ghostButtonTapped = { [weak self] in
            self?.showGhostPopupView()
        }
        
        cell.bottomView.heartButtonTapped = { [weak self] in
            cell.bottomView.isLiked.toggle()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = FeedDetailViewController()
        detailViewController.hidesBottomBarWhenPushed = true
        detailViewController.getFeedData(data: dummyData[indexPath.row])
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension HomeViewController: WablePopupDelegate {

    func cancleButtonTapped() {
        self.ghostPopupView?.removeFromSuperview()
    }
    
    func confirmButtonTapped() {
        self.ghostPopupView?.removeFromSuperview()
        print("투명도 버튼 클릭: 서버통신 이후에 투명도 낮추도록 하기")
    }
}
