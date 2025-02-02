//
//  InfoPageViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/7/25.
//

import Foundation
import Combine

final class InfoPageViewModel {
    private let service: InfoAPI
    private let userDefaultsManager: UserDefaultsManager
    
    init(
        service: InfoAPI = .shared,
        userDefaultsManager: UserDefaultsManager = UserDefaultsManagerImpl()
    ) {
        self.service = service
        self.userDefaultsManager = userDefaultsManager
    }
}

extension InfoPageViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let currentIndex: AnyPublisher<Int, Never>
    }
    
    struct Output {
        let showBadges: AnyPublisher<(Bool, Bool), Never>
        let hideNewsBadge: AnyPublisher<Void, Never>
        let hideNoticeBadge: AnyPublisher<Void, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        
        let existingNewsCount: Int = userDefaultsManager.load(forKey: UserDefaultsKeys.newsCount, as: Int.self) ?? 0
        let existingNoticeCount: Int = userDefaultsManager.load(forKey: UserDefaultsKeys.noticeCount, as: Int.self) ?? 0
        
        let infoCount = input.viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<InfoCountDTO?, Never> in
                guard let self else {
                    return .just(nil)
                }
                return service.getInfoCount()
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
        
        let showBadges = infoCount
            .map { ($0.newsCount > existingNewsCount, $0.noticeCount > existingNoticeCount) }
            .eraseToAnyPublisher()
        
        let hideNewsBadge = input.currentIndex
            .filter { $0 == Constants.newsIndexNumber }
            .combineLatest(infoCount)
            .map { $1 }
            .filter { $0.newsCount > existingNewsCount }
            .map { $0.newsCount }
            .handleEvents(receiveOutput: { [weak self] newsCount in
                self?.userDefaultsManager.save(newsCount, forKey: UserDefaultsKeys.newsCount)
            })
            .map { _ in () }
            .eraseToAnyPublisher()
        
        let hideNoticeBadge = input.currentIndex
            .filter { $0 == Constants.noticeIndexNumber }
            .combineLatest(infoCount)
            .map { $1 }
            .filter { $0.noticeCount > existingNoticeCount }
            .map { $0.noticeCount }
            .handleEvents(receiveOutput: { [weak self] noticeCount in
                self?.userDefaultsManager.save(noticeCount, forKey: UserDefaultsKeys.noticeCount)
            })
            .map { _ in () }
            .eraseToAnyPublisher()
        
        input.currentIndex
            .compactMap { index -> String? in
                switch index {
                case 0: 
                    return "click_gameschedule"
                case 1:
                    return "click_ranking"
                case 2:
                    return "click_news"
                case 3:
                    return "click_announcement"
                default:
                    return nil
                }
            }
            .sink { AmplitudeManager.shared.trackEvent(tag: $0) }
            .store(in: cancelBag)
        
        return Output(
            showBadges: showBadges,
            hideNewsBadge: hideNewsBadge,
            hideNoticeBadge: hideNoticeBadge
        )
    }
}

extension InfoPageViewModel {
    
    // MARK: - UserDefaultsKey
    
    enum UserDefaultsKeys: UserDefaultsKey {
        case newsCount
        case noticeCount
        
        var value: String {
            switch self {
            case .newsCount: "newsCount"
            case .noticeCount: "noticeCount"
            }
        }
    }
    
    // MARK: - Constants
    
    enum Constants {
        static let newsIndexNumber = 2
        static let noticeIndexNumber = 3
    }
}
