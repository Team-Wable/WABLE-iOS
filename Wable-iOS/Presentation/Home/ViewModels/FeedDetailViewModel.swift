//
//  FeedDetailViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/30/24.
//

import Foundation
import Combine

final class FeedDetailViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let networkProvider: NetworkServiceType
    
    private var getPostData = PassthroughSubject<FeedDetailResponseDTO, Never>()
    private let toggleLikeButton = PassthroughSubject<Bool, Never>()
    var isLikeButtonClicked: Bool = false
    private var getPostReplyData = PassthroughSubject<[FeedDetailReplyDTO], Never>()
    private let clickedRadioButtonState = PassthroughSubject<Int, Never>()
    private let toggleCommentLikeButton = PassthroughSubject<Bool, Never>()
    private let postReplyCompleted = PassthroughSubject<Int, Never>()
    
    var isCommentLikeButtonClicked: Bool = false
    var cursor: Int = -1
    
    var feedReplyData: [FeedDetailReplyDTO] = []
    var feedReplyDatas: [FeedDetailReplyDTO] = []
    
    struct Input {
        let viewUpdate: AnyPublisher<Int, Never>?
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?
        let tableViewUpdata: AnyPublisher<Int, Never>?
        let commentLikeButtonTapped: AnyPublisher<(Bool, Int, String), Never>?
        let postButtonTapped: AnyPublisher<(WriteReplyRequestDTO, Int), Never>
    }
    
    struct Output {
        let getPostData: PassthroughSubject<FeedDetailResponseDTO, Never>
        let toggleLikeButton: PassthroughSubject<Bool, Never>
        let getPostReplyData: PassthroughSubject<[FeedDetailReplyDTO], Never>
        let toggleCommentLikeButton: PassthroughSubject<Bool, Never>
        let clickedButtonState: PassthroughSubject<Int, Never>
        let postReplyCompleted: PassthroughSubject<Int, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.viewUpdate?
            .sink { value in
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let postResult = try await
                            self.getPostDetailDataAPI(accessToken: accessToken, contentId: value)
                            if let data = postResult?.data {
                                self.isLikeButtonClicked = data.isLiked
                                self.getPostData.send(data)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: self.cancelBag)
        
        input.tableViewUpdata?
            .sink { [self] value in
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let postReplyResult = try await
                            self.getPostReplyDataAPI(accessToken: accessToken, contentId: value)
                            if let data = postReplyResult?.data {
                                if self.cursor == -1 {
                                    self.feedReplyDatas = []
                                    
                                    var tempArray: [FeedDetailReplyDTO] = []
                                    
                                    for content in data {
                                        tempArray.append(content)
                                    }
                                    self.feedReplyDatas = tempArray
                                    self.getPostReplyData.send(data)
                                } else {
                                    var tempArray: [FeedDetailReplyDTO] = []
                                    
                                    if data.isEmpty {
                                        self.cursor = -1
                                    } else {
                                        
                                        for content in data {
                                            tempArray.append(content)
                                        }
                                        self.feedReplyDatas.append(contentsOf: tempArray)
                                        self.getPostReplyData.send(data)
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: self.cancelBag)
        
        input.postButtonTapped
            .sink { value in
                AmplitudeManager.shared.trackEvent(tag: "click_write_comment")
                Task {
                    do {
                        try await self.postWriteReplyContentAPI(
                            commentText: value.0.commentText,
                            contentId: value.1
                        )
                        self.postReplyCompleted.send(0)
                    }
                }
            }
            .store(in: self.cancelBag)
        
        return Output(getPostData: getPostData,
                      toggleLikeButton: toggleLikeButton,
                      getPostReplyData: getPostReplyData,
                      toggleCommentLikeButton: toggleCommentLikeButton,
                      clickedButtonState: clickedRadioButtonState,
                      postReplyCompleted: postReplyCompleted)
    }
    
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Network

extension FeedDetailViewModel {
    private func getPostDetailDataAPI(accessToken: String, contentId: Int) async throws -> BaseResponse<FeedDetailResponseDTO>? {
        do {
            let result: BaseResponse<FeedDetailResponseDTO>? = try
            await self.networkProvider.donNetwork(type: .get, baseURL: Config.baseURL + "v2/content/\(contentId)", accessToken: accessToken, body: EmptyBody(), pathVariables: ["":""])
            return result
        } catch {
            return nil
        }
    }
    
    private func getPostReplyDataAPI(accessToken: String, contentId: Int) async throws -> BaseResponse<[FeedDetailReplyDTO]>? {
        do {
            let result: BaseResponse<[FeedDetailReplyDTO]>? = try await
            self.networkProvider.donNetwork(type: .get,
                                            baseURL: Config.baseURL + "v2/content/\(contentId)/comments",
                                            accessToken: accessToken,
                                            body: EmptyBody(),
                                            pathVariables: ["cursor":"\(cursor)"])
            return result
        } catch {
            return nil
        }
    }
    
    private func postWriteReplyContentAPI(commentText: String, contentId: Int) async throws -> Void {
        // URL 생성
        guard let url = URL(string: Config.baseURL + "v1/content/\(contentId)/comment") else { return }
        // Access Token 로드
        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }
        
        // 전송할 JSON 데이터
        let parameters: [String: Any] = [
            "notificationTriggerType": "comment",
            "commentText": commentText
        ]
        
        // URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Content-Type을 application/json으로 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // JSON 데이터를 HTTP Body에 추가
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // *** 전체 요청 내용 출력 ***
        print("=== HTTP Request ===")
        print("URL:", request.url?.absoluteString ?? "No URL")
        print("HTTP Method:", request.httpMethod ?? "No method")
        print("Headers:", request.allHTTPHeaderFields ?? "No headers")
        
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Body:\n", bodyString)
        } else {
            print("No body data")
        }

        // URLSession으로 비동기 요청 보내기
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 응답 처리
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        // *** 전체 응답 내용 출력 ***
        print("=== HTTP Response ===")
        print("Response status code:", httpResponse.statusCode)
        print("Response headers:", httpResponse.allHeaderFields)

        // 상태 코드 확인
        if httpResponse.statusCode != 201 {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
        }
        
        // 응답 데이터 확인
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
        }
        
        // 응답 데이터 출력
        print("Response data:", responseString)
        
        return
    }
}
