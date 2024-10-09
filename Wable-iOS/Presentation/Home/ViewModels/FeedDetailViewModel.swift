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
    var isButtonEnabled = PassthroughSubject<Bool, Never>()
    
    // MARK: - Input
    
    let paginationDidAction = PassthroughSubject<Int, Never>()
    let viewWillAppear = PassthroughSubject<Int, Never>()

    // MARK: - Output
    
    let replyDatas = PassthroughSubject<[FeedDetailReplyDTO], Never>()
    let replyPaginationDatas = PassthroughSubject<[FeedDetailReplyDTO], Never>()
    
    var isCommentLikeButtonClicked: Bool = false
    var cursor: Int = -1
    
    var feedReplyData: [FeedDetailReplyDTO] = []
    var feedReplyPaginationData: [FeedDetailReplyDTO] = []
    
    struct Input {
        let viewUpdate: AnyPublisher<Int, Never>?
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?
        let commentLikeButtonTapped: AnyPublisher<(Bool, Int, String), Never>?
        let postButtonTapped: AnyPublisher<(WriteReplyRequestDTO, Int, String), Never>
    }
    
    struct Output {
        let getPostData: PassthroughSubject<FeedDetailResponseDTO, Never>
        let toggleLikeButton: PassthroughSubject<Bool, Never>
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
        
        input.postButtonTapped
            .sink { value in
                
                let trimmedText = value.0.commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedText != value.2 + StringLiterals.Home.placeholder else {
                            print("Placeholder 텍스트는 전송하지 않음")
                            return
                        }
                self.isButtonEnabled.send(false)

                print("💦💦💦💦💦💦💦💦💦💦postButtonTapped💦💦💦💦💦💦💦💦💦💦")
                AmplitudeManager.shared.trackEvent(tag: "click_write_comment")
                Task {
                    do {

                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let result = try await self.postWriteReplyAPI(accessToken: accessToken, commentText: value.0.commentText, contentId: value.1, notificationTriggerType: "comment")
                            
                            if result?.status == 201 {
                                self.postReplyCompleted.send(0)
                            }
                            print("\(result)👻👻👻👻👻👻👻👻👻👻👻👻👻👻👻👻")
                        }
                    }
                }
            }
            .store(in: self.cancelBag)
        
        return Output(getPostData: getPostData,
                      toggleLikeButton: toggleLikeButton,
                      toggleCommentLikeButton: toggleCommentLikeButton,
                      clickedButtonState: clickedRadioButtonState,
                      postReplyCompleted: postReplyCompleted)
    }
    
    private func transform() {
        viewWillAppear
            .sink { [self] contentID in
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let postReplyResult = try await
                            self.getPostReplyDataAPI(accessToken: accessToken, contentId: contentID)
                            if let data = postReplyResult?.data {
                                self.replyDatas.send(data)
                            }
                        }
                    }
                }
            }
            .store(in: cancelBag)
        
        paginationDidAction
            .sink { [self] contentID in
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let postReplyResult = try await
                            self.getPostReplyDataAPI(accessToken: accessToken, contentId: contentID)
                            if let data = postReplyResult?.data {
                                self.replyPaginationDatas.send(data)
                            }
                        }
                    }
                }
            }
            .store(in: cancelBag)
    }
    
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
        transform()
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
    
    private func postWriteReplyAPI(accessToken: String, commentText: String, contentId: Int, notificationTriggerType: String) async throws -> BaseResponse<EmptyResponse>? {
        do {
            let result: BaseResponse<EmptyResponse>? = try await
            self.networkProvider.donNetwork(
                type: .post,
                baseURL: Config.baseURL + "v1/content/\(contentId)/comment",
                accessToken: accessToken,
                body: WriteReplyRequestDTO(commentText: commentText, notificationTriggerType: notificationTriggerType),
                pathVariables: ["":""]
            )
            self.isButtonEnabled.send(true)

            return result
        } catch {
            self.isButtonEnabled.send(true)
            return nil
        }
    }
}
