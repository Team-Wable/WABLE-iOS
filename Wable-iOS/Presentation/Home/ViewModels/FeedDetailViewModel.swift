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
    
//    private var isFirstReasonChecked = false
//    private var isSecondReasonChecked = false
//    private var isThirdReasonChecked = false
//    private var isFourthReasonChecked = false
//    private var isFifthReasonChecked = false
//    private var isSixthReasonChecked = false
    
    struct Input {
        let viewUpdate: AnyPublisher<Int, Never>?
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?
        let tableViewUpdata: AnyPublisher<Int, Never>?
        let commentLikeButtonTapped: AnyPublisher<(Bool, Int, String), Never>?
        let postButtonTapped: AnyPublisher<(WriteReplyRequestDTO, Int), Never>
//        let firstReasonButtonTapped: AnyPublisher<Void, Never>?
//        let secondReasonButtonTapped: AnyPublisher<Void, Never>?
//        let thirdReasonButtonTapped: AnyPublisher<Void, Never>?
//        let fourthReasonButtonTapped: AnyPublisher<Void, Never>?
//        let fifthReasonButtonTapped: AnyPublisher<Void, Never>?
//        let sixthReasonButtonTapped: AnyPublisher<Void, Never>?
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
        
//        input.likeButtonTapped?
//            .sink {  value in
//                Task {
//                    do {
//                        if value.0 {
//                            let statusCode = try await self.deleteLikeButtonAPI(contentId: value.1)?.status
//                            if statusCode == 200 {
//                                self.toggleLikeButton.send(!value.0)
//                            }
//                        } else {
//                            let statusCode = try await self.postLikeButtonAPI(contentId: value.1)?.status
//                            if statusCode == 201 {
//                                self.toggleLikeButton.send(value.0)
//                            }
//                        }
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            .store(in: self.cancelBag)
        
        input.tableViewUpdata?
            .sink { [self] value in
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let postReplyResult = try await
                            self.getPostReplyDataAPI(accessToken: accessToken, contentId: value)
                            if let data = postReplyResult?.data {
//                                if let lastCommentId = data.last?.commentId {
//                                    self.cursor = lastCommentId
//                                }
                                if self.cursor == -1 {
                                    self.feedReplyDatas = []
                                    
                                    var tempArray: [FeedDetailReplyDTO] = []
                                    
                                    for content in data {
                                        tempArray.append(content)
                                    }
                                    self.feedReplyDatas.append(contentsOf: tempArray)
                                    self.getPostReplyData.send(tempArray)
                                } else {
                                    var tempArray: [FeedDetailReplyDTO] = []
                                    
                                    for content in data {
                                        tempArray.append(content)
                                    }
                                    self.feedReplyDatas.append(contentsOf: tempArray)
                                    self.getPostReplyData.send(tempArray)
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: self.cancelBag)
        
//        input.commentLikeButtonTapped?
//            .sink {  value in
//                Task {
//                    do {
//                        if value.0 == true {
//                            let statusCode = try await self.deleteCommentLikeButtonAPI(commentId: value.1)?.status
//                            if statusCode == 201 {
//                                self.toggleCommentLikeButton.send(!value.0)
//                            }
//                        } else {
//                            let statusCode = try await self.postCommentLikeButtonAPI(commentId: value.1, alarmText: value.2)?.status
//                            if statusCode == 201 {
//                                self.toggleCommentLikeButton.send(value.0)
//                            }
//                        }
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            .store(in: self.cancelBag)
        
//        input.firstReasonButtonTapped?
//            .sink { [weak self] _ in
//                self?.isFirstReasonChecked.toggle()
//                self?.clickedRadioButtonState.send(1)
//            }
//            .store(in: cancelBag)
//        
//        input.secondReasonButtonTapped?
//            .sink { [weak self] _ in
//                self?.isSecondReasonChecked.toggle()
//                self?.clickedRadioButtonState.send(2)
//            }
//            .store(in: cancelBag)
//        
//        input.thirdReasonButtonTapped?
//            .sink { [weak self] _ in
//                self?.isThirdReasonChecked.toggle()
//                self?.clickedRadioButtonState.send(3)
//            }
//            .store(in: cancelBag)
//        
//        input.fourthReasonButtonTapped?
//            .sink { [weak self] _ in
//                self?.isFourthReasonChecked.toggle()
//                self?.clickedRadioButtonState.send(4)
//            }
//            .store(in: cancelBag)
//        
//        input.fifthReasonButtonTapped?
//            .sink { [weak self] _ in
//                self?.isFifthReasonChecked.toggle()
//                self?.clickedRadioButtonState.send(5)
//            }
//            .store(in: cancelBag)
//        
//        input.sixthReasonButtonTapped?
//            .sink { [weak self] _ in
//                self?.isSixthReasonChecked.toggle()
//                self?.clickedRadioButtonState.send(6)
//            }
//            .store(in: cancelBag)
        
        input.postButtonTapped
            .sink { value in
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
    
//    private func postWriteReplyContentAPI(accessToken: String, commentText: String, contentId: Int, notificationTriggerType: String) async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            let result: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(
//                type: .post,
//                baseURL: Config.baseURL + "v1/content/\(contentId)/comment",
//                accessToken: accessToken,
//                body: WriteReplyRequestDTO(commentText: commentText, notificationTriggerType: notificationTriggerType),
//                pathVariables: ["":""]
//            )
//            return result
//        } catch {
//            return nil
//        }
//    }
    
    private func postWriteReplyContentAPI(commentText: String, contentId: Int) async throws -> Void {
        guard let url = URL(string: Config.baseURL + "v2/content/\(contentId)/comment") else { return }
        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }
        
        let parameters: [String: Any] = [
            "commentText" : commentText,
            "notificationTriggerType" : "comment"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Multipart form data 생성
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        var requestBodyData = Data()
        
        // 게시글 본문 데이터 추가
        requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBodyData.append("Content-Disposition: form-data; name=\"text\"\r\n\r\n".data(using: .utf8)!)
        requestBodyData.append(try! JSONSerialization.data(withJSONObject: parameters, options: []))
        requestBodyData.append("\r\n".data(using: .utf8)!)
        
//        if let image = photoImage {
//            let imageData = image.jpegData(compressionQuality: 0.1)!
//            
//            // 게시글 이미지 데이터 추가
//            requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
//            requestBodyData.append("Content-Disposition: form-data; name=\"image\"; filename=\"dontbe.jpeg\"\r\n".data(using: .utf8)!)
//            requestBodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            requestBodyData.append(imageData)
//            requestBodyData.append("\r\n".data(using: .utf8)!)
//        }
        
        requestBodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // HTTP body에 데이터 설정
        request.httpBody = requestBodyData
        
        // URLSession으로 비동기 요청 보내기
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 응답 처리
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        print("Response status code:", httpResponse.statusCode)
        
        if httpResponse.statusCode != 201 {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
        }
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
        }
        
        print("Response data:", responseString)  // 서버 응답 데이터를 처리한 후 출력
        
        return
    }
    
//    func postDownTransparency(accessToken: String, alarmTriggerType: String, targetMemberId: Int, alarmTriggerId: Int, ghostReason: String) async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            let result: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(type: .post,
//                                            baseURL: Config.baseURL + "v1/ghost2",
//                                            accessToken: accessToken,
//                                            body: PostTransparencyRequestDTO(
//                                                alarmTriggerType: alarmTriggerType,
//                                                targetMemberId: targetMemberId,
//                                                alarmTriggerId: alarmTriggerId,
//                                                ghostReason: ghostReason
//                                            ),
//                                            pathVariables: ["":""])
//            return result
//        } catch {
//            return nil
//        }
//    }
//    
//    private func postLikeButtonAPI(contentId: Int) async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
//            let requestDTO = ContentLikeRequestDTO(alarmTriggerType: "contentLiked")
//            let data: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(
//                type: .post,
//                baseURL: Config.baseURL + "/content/\(contentId)/liked",
//                accessToken: accessToken,
//                body: requestDTO,
//                pathVariables: ["":""]
//            )
//            print ("👻👻👻👻👻게시물 좋아요 버튼 클릭👻👻👻👻👻")
//            return data
//        } catch {
//            return nil
//        }
//    }
//    
//    private func deleteLikeButtonAPI(contentId: Int) async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
//            let data: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(
//                type: .delete,
//                baseURL: Config.baseURL + "/content/\(contentId)/unliked",
//                accessToken: accessToken,
//                body: EmptyBody(),
//                pathVariables: ["":""]
//            )
//            print ("👻👻👻👻👻게시물 좋아요 취소 버튼 클릭👻👻👻👻👻")
//            return data
//        } catch {
//            return nil
//        }
//    }
//    
//    private func postCommentLikeButtonAPI(commentId: Int, alarmText: String)  async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
//            let requestDTO = CommentLikeRequestDTO(notificationTriggerType: "commentLiked", notificationText: alarmText)
//            let data: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(
//                type: .post,
//                baseURL: Config.baseURL + "/comment/\(commentId)/liked",
//                accessToken: accessToken,
//                body: requestDTO,
//                pathVariables: ["":""]
//            )
//            print ("👻👻👻👻👻답글 좋아요 버튼 클릭👻👻👻👻👻")
//            return data
//        } catch {
//            return nil
//        }
//    }
//    
//    private func deleteCommentLikeButtonAPI(commentId: Int)  async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
//            let data: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(
//                type: .delete,
//                baseURL: Config.baseURL + "/comment/\(commentId)/unliked",
//                accessToken: accessToken,
//                body: EmptyBody(),
//                pathVariables: ["":""]
//            )
//            print ("👻👻👻👻👻답글 좋아요 취소 버튼 클릭👻👻👻👻👻")
//            return data
//        } catch {
//            return nil
//        }
//    }
//    
//    func postReportButtonAPI(reportTargetNickname: String, relateText: String) async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
//            let data: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(
//                type: .post,
//                baseURL: Config.baseURL + "/report/slack",
//                accessToken: accessToken,
//                body: ReportRequestDTO(
//                    reportTargetNickname: reportTargetNickname,
//                    relateText: relateText
//                ),
//                pathVariables: ["":""]
//            )
//            return data
//        } catch {
//            return nil
//        }
//    }
}
