//
//  ViewitRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class ViewitRepositoryImpl {
    private let provider = APIProvider<ViewitTargetType>()
}

extension ViewitRepositoryImpl: ViewitRepository {
    func deleteViewit(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteViewit(viewitID: viewitID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func deleteViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteViewitLiked(viewitID: viewitID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func postViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createViewitLiked(viewitID: viewitID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func fetchViewitList(cursor: Int) -> AnyPublisher<[Viewit], WableError> {
        return provider.request(
            .fetchViewitList(cursor: cursor),
            for: [DTO.Response.FetchViewits].self
        )
        .map(ViewitMapper.toDomain)
        .mapWableError()
    }
    
    func createViewit(
        thumbnailImageURLString: String,
        urlString: String,
        siteName: String,
        title: String,
        text: String
    ) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createViewitPost(
                request: DTO.Request.CreateViewitPost(
                    viewitImage: thumbnailImageURLString,
                    viewitLink: urlString,
                    viewitTitle: siteName,
                    viewitText: title,
                    viewitName: text
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
}

// MARK: - Mock

struct MockViewitRepository: ViewitRepository {
    private var delaySeconds: Double { return .random(in: 1...3) }
    
    func deleteViewit(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return .just(())
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func deleteViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return .just(())
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func postViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return .just(())
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchViewitList(cursor: Int) -> AnyPublisher<[Viewit], WableError> {
        let profileURL = URL(string: "https://fastly.picsum.photos/id/387/28/28.jpg?hmac=VwvoFSihTd_P4DSfzpjQlqIBbXa6BHDDAFxAPih7TjY")
        let imageURL = URL(string: "https://fastly.picsum.photos/id/98/148/84.jpg?hmac=7DON_uyl8GnjimtkXbFq8r4X9opH2ll8scJOGbE7Els")
        let mockItems: [Viewit] = [
            Viewit(
                userID: 1,
                userNickname: "김와블",
                userProfileURL: profileURL,
                id: 101,
                thumbnailURL: imageURL,
                siteURL: URL(string: "https://www.youtube.com/watch?v=example1"),
                siteName: "youtube",
                title: "2024년 개발자가 알아야 할 iOS 업데이트",
                text: "요즘 개발자들에게 꼭 필요한 iOS 최신 기능들! 이 영상 완전 추천해요~",
                time: Date(),
                status: .blind,
                like: Like(status: false, count: 24)
            ),
            Viewit(
                userID: 2,
                userNickname: "개발왕",
                userProfileURL: profileURL,
                id: 102,
                thumbnailURL: imageURL,
                siteURL: URL(string: "https://www.youtube.com/watch?v=example2"),
                siteName: "youtube",
                title: "Swift 5.10 완벽 정리 - 이것만 알면 당신도 iOS 개발자",
                text: "Swift 언어의 최신 기능들이 정말 잘 정리되어 있어요. 초보자부터 숙련자까지 모두에게 도움이 될 듯!",
                time: Date().addingTimeInterval(-3600 * 24),
                status: .normal,
                like: Like(status: true, count: 56)
            ),
            Viewit(
                userID: 3,
                userNickname: "iOS마스터",
                userProfileURL: profileURL,
                id: 103,
                thumbnailURL: imageURL,
                siteURL: URL(string: "https://www.youtube.com/watch?v=example3"),
                siteName: "youtube",
                title: "UIKit vs SwiftUI - 2025년에도 UIKit이 필요한 이유",
                text: "최신 트렌드는 SwiftUI지만 아직 UIKit이 필요한 상황들이 많이 있어요. 이 영상이 그 이유를 잘 설명해줍니다.",
                time: Date().addingTimeInterval(-3600 * 48),
                status: .normal,
                like: Like(status: false, count: 42)
            ),
            Viewit(
                userID: 4,
                userNickname: "앱디자이너",
                userProfileURL: profileURL,
                id: 104,
                thumbnailURL: imageURL,
                siteURL: URL(string: "https://www.youtube.com/watch?v=example4"),
                siteName: "youtube",
                title: "모바일 앱 UX/UI 디자인 트렌드 2025",
                text: "앱 디자인 트렌드가 어떻게 변하고 있는지 정말 잘 보여주는 영상입니다. 개발자와 디자이너 모두에게 추천!",
                time: Date().addingTimeInterval(-3600 * 72),
                status: .blind,
                like: Like(status: false, count: 18)
            ),
            Viewit(
                userID: 5,
                userNickname: "코딩고수",
                userProfileURL: profileURL,
                id: 105,
                thumbnailURL: imageURL,
                siteURL: URL(string: "https://www.youtube.com/watch?v=example5"),
                siteName: "youtube",
                title: "클린 아키텍처로 iOS 앱 설계하기",
                text: "MVVM, Clean Architecture에 대해 정말 쉽게 설명해주는 영상이에요. 구현 예제도 있어서 바로 적용할 수 있어요!",
                time: Date().addingTimeInterval(-3600 * 96),
                status: .normal,
                like: Like(status: true, count: 103)
            )
        ]
        
        return .just(mockItems)
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func createViewit(
        thumbnailImageURLString: String,
        urlString: String,
        siteName: String,
        title: String,
        text: String
    ) -> AnyPublisher<Void, WableError> {
        return .just(())
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
