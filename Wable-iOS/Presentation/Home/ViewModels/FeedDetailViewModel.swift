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
    private let homeAPI = HomeAPI.shared
    
    private let getPostData = PassthroughSubject<FeedDetailResponseDTO, Never>()
    private let toggleLikeButton = PassthroughSubject<Bool, Never>()
    var isLikeButtonClicked: Bool = false
    private let getPostReplyData = PassthroughSubject<[FeedReplyListDTO], Never>()
    private let clickedRadioButtonState = PassthroughSubject<Int, Never>()
    private let toggleCommentLikeButton = PassthroughSubject<Bool, Never>()
    private let postReplyCompleted = PassthroughSubject<Int, Never>()
    private let replyTargetNickname = PassthroughSubject<String, Never>()
    
    private var parentCommentAndWriterID = CurrentValueSubject<(Int, Int),Never>((-1, -1))
    private var feedWriterNickname = String()
    var isProcessingPostButton = false
    let contentIDSubject = CurrentValueSubject<Int?, Never>(nil)
    
    // MARK: - Input
    
    let paginationDidAction = PassthroughSubject<Int, Never>()
    let viewWillAppear = PassthroughSubject<Int, Never>()

    // MARK: - Output
    
    // TODO: - 페이징 로직 수정
    
    let replyDatas = PassthroughSubject<[FlattenReplyModel], Never>()
    let replyPaginationDatas = PassthroughSubject<[FlattenReplyModel], Never>()
    private let replyDatasSubject = CurrentValueSubject<[FlattenReplyModel], Never>([])
    
    var isCommentLikeButtonClicked: Bool = false
    var cursor: Int = -1
    
    struct Input {
        let viewUpdate: AnyPublisher<Int?, Never>?
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?
        let commentLikeButtonTapped: AnyPublisher<(Bool, Int, String), Never>?
        let postButtonTapped: AnyPublisher<(String, Int), Never>
        let replyButtonDidTapped: AnyPublisher<Int?,Never>
    }
    
    struct Output {
        let getPostData: PassthroughSubject<FeedDetailResponseDTO, Never>
        let toggleLikeButton: PassthroughSubject<Bool, Never>
        let toggleCommentLikeButton: PassthroughSubject<Bool, Never>
        let clickedButtonState: PassthroughSubject<Int, Never>
        let postReplyCompleted: PassthroughSubject<Int, Never>
        let replyTargetNickname: PassthroughSubject<String, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.viewUpdate?
            .sink { [weak self] value in
                guard let self = self else { return }
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            
                            // 상단 게시글 정보 불러오기
                            let postResult = try await
                            self.getPostDetailDataAPI(accessToken: accessToken, contentId: value ?? Int())
                            
                            guard let data = postResult?.data else { return }
                            self.isLikeButtonClicked = data.isLiked
                            self.getPostData.send(data)
                            self.feedWriterNickname = data.memberNickname
                            self.replyTargetNickname.send(self.feedWriterNickname + StringLiterals.Home.placeholder)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: self.cancelBag)
        
        input.postButtonTapped
            .sink { [weak self] value in
                guard let self = self, !self.isProcessingPostButton else { return }
                
                self.isProcessingPostButton = true
                
                AmplitudeManager.shared.trackEvent(tag: "click_write_comment")
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let result = try await self.postWriteReplyAPI(accessToken: accessToken,
                                                                            commentText: value.0,
                                                                            contentId: value.1,
                                                                            parentCommentID: self.parentCommentAndWriterID.value.0,
                                                                            parentCommentWriterID: self.parentCommentAndWriterID.value.1)
                            
                            if result?.status == 201 {
                                try await self.handlePostReplySuccess(accessToken: accessToken, contentId: value.1)
                            }
                        }
                    } catch {
                        print("error in postButtonTapped: \(error)")
                    }
                    self.isProcessingPostButton = false
                }
            }
            .store(in: self.cancelBag)
        
        
        input.replyButtonDidTapped
            .sink { [weak self] index in
                guard let self else { return }
                let replyDatas = replyDatasSubject.value
                
                if let index  = index {
                    let parentCommentID = replyDatas[index].commentID
                    let parentWriterID = replyDatas[index].memberID
                    let parentNickname = replyDatas[index].memberNickname
                    
                    parentCommentAndWriterID.send((parentCommentID,parentWriterID))
                    replyTargetNickname.send(parentNickname + StringLiterals.Home.placeholderForChildReply)
                } else {
                    parentCommentAndWriterID.send((-1, -1))
                    replyTargetNickname.send(feedWriterNickname + StringLiterals.Home.placeholder)
                }
            }
            .store(in: self.cancelBag)
        
        return Output(getPostData: getPostData,
                      toggleLikeButton: toggleLikeButton,
                      toggleCommentLikeButton: toggleCommentLikeButton,
                      clickedButtonState: clickedRadioButtonState,
                      postReplyCompleted: postReplyCompleted,
                      replyTargetNickname: replyTargetNickname)
    }
    
    private func transform() {
        viewWillAppear
            .sink { [self] contentID in
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let postReplyResult = try await
                            self.getReplyListAPI(accessToken: accessToken, contentId: contentID)
                            guard let data = postReplyResult?.data else { return }
                            let flattenDatas = data.toFlattenedReplyList()
                            self.replyDatas.send(flattenDatas)
                            self.replyDatasSubject.send(flattenDatas)
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
                            self.getReplyListAPI(accessToken: accessToken, contentId: contentID)
                            guard let data = postReplyResult?.data else { return }
                            let flattenDatas = data.toFlattenedReplyList()
                            self.replyPaginationDatas.send(flattenDatas)
                        }
                    }
                }
            }
            .store(in: cancelBag)
    }
    
    private func handlePostReplySuccess(accessToken: String, contentId: Int) async throws {
        self.postReplyCompleted.send(0)
        self.replyTargetNickname.send(self.feedWriterNickname + StringLiterals.Home.placeholder)
        
        let postResult = try await self.getPostDetailDataAPI(accessToken: accessToken, contentId: contentId)
        
        guard let data = postResult?.data else { return }
        self.isLikeButtonClicked = data.isLiked
        self.getPostData.send(data)
        self.feedWriterNickname = data.memberNickname
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
            await self.networkProvider.donNetwork(type: .get, baseURL: Config.baseURL + "v3/content/\(contentId)", accessToken: accessToken, body: EmptyBody(), pathVariables: ["":""])
            return result
        } catch {
            return nil
        }
    }
    
    // TODO: - 엔드포인트 리터럴화
    
    private func getReplyListAPI(accessToken: String, contentId: Int) async throws -> BaseResponse<[FeedReplyListDTO]>? {
        do {
            let result: BaseResponse<[FeedReplyListDTO]>? = try await
            self.networkProvider.donNetwork(type: .get,
                                            baseURL: Config.baseURL + "v3/content/\(contentId)/comments",
                                            accessToken: accessToken,
                                            body: EmptyBody(),
                                            pathVariables: ["cursor":"\(cursor)"])
            return result
        } catch {
            return nil
        }
    }
    
    private func postWriteReplyAPI(accessToken: String, commentText: String, contentId: Int, parentCommentID: Int, parentCommentWriterID: Int) async throws -> BaseResponse<EmptyResponse>? {
        do {
            let result: BaseResponse<EmptyResponse>? = try await
            self.networkProvider.donNetwork(
                type: .post,
                baseURL: Config.baseURL + "v3/content/\(contentId)/comment",
                accessToken: accessToken,
                body: WriteReplyRequestV3DTO(commentText: commentText,
                                             parentCommentID: parentCommentID,
                                             parentCommentWriterID: parentCommentWriterID),
                pathVariables: ["":""]
            )
            return result
        } catch {
            return nil
        }
    }
}
