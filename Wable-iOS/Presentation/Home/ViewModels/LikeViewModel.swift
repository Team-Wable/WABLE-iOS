//
//  LikeViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 9/1/24.
//

import Combine
import Foundation

final class LikeViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let networkProvider: NetworkServiceType
    
    private let toggleLikeButton = PassthroughSubject<Bool, Never>()
    private let popView = PassthroughSubject<Void, Never>()
    
    var isLikeButtonTapped: Bool = false
    
    struct Input {
        let likeButtonTapped: AnyPublisher<(Bool, Int), Never>?
        let deleteButtonDidTapped: AnyPublisher<Int, Never>?
    }

    struct Output {
        let toggleLikeButton: PassthroughSubject<Bool, Never>
        let popView: PassthroughSubject<Void, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.likeButtonTapped?
            .sink { value in
                Task {
                    do {
                        if value.0 == true {
                            let statusCode = try await self.postUnlikeButtonAPI(contentId: value.1)?.status
                            if statusCode == 200 {
                                self.toggleLikeButton.send(!value.0)
                            }
                        } else {
                            let statusCode = try await self.postLikeButtonAPI(contentId: value.1)?.status
                            if statusCode == 201 {
                                self.toggleLikeButton.send(value.0)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: self.cancelBag)
        
        input.deleteButtonDidTapped?
            .sink { value in
                Task {
                    do {
                        if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                            let statusCode = try await self.deletePostAPI(accessToken: accessToken, contentId: value)?.status
                            if statusCode == 200 {
                                self.popView.send()
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: self.cancelBag)
        
        return Output(toggleLikeButton: toggleLikeButton,
                      popView: popView)
    }
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LikeViewModel {
    private func postLikeButtonAPI(contentId: Int) async throws -> BaseResponse<EmptyResponse>? {
        do {
            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
            let requestDTO = ContentLikeRequestDTO(alarmTriggerType: "contentLiked")
            let data: BaseResponse<EmptyResponse>? = try await
            self.networkProvider.donNetwork(
                type: .post,
                baseURL: Config.baseURL + "v1/content/\(contentId)/liked",
                accessToken: accessToken,
                body: requestDTO,
                pathVariables: ["":""]
            )
            print("postLikeButtonAPI: \(data)")
            return data
        } catch {
            return nil
        }
    }
    
    private func postUnlikeButtonAPI(contentId: Int) async throws -> BaseResponse<EmptyResponse>? {
        do {
            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
            let data: BaseResponse<EmptyResponse>? = try await
            self.networkProvider.donNetwork(
                type: .delete,
                baseURL: Config.baseURL + "v1/content/\(contentId)/unliked",
                accessToken: accessToken,
                body: EmptyBody(),
                pathVariables: ["":""]
            )
            print("postUnlikeButtonAPI: \(data)")
            return data
        }
    }
    
    func deletePostAPI(accessToken: String, contentId: Int) async throws -> BaseResponse<EmptyResponse>? {
        let accessToken = accessToken
        do {
            let result: BaseResponse<EmptyResponse>? = try
            await self.networkProvider.donNetwork(type: .delete, baseURL: Config.baseURL + "v1/content/\(contentId)", accessToken: accessToken, body: EmptyBody(), pathVariables: ["":""])
            print("deletePostAPI result: \(result)")
            return result
        } catch {
            return nil
        }
    }
    
    func postDownTransparency(accessToken: String, alarmTriggerType: String, targetMemberId: Int, alarmTriggerId: Int, ghostReason: String) async throws -> BaseResponse<EmptyResponse>? {
        do {
            let result: BaseResponse<EmptyResponse>? = try await
            self.networkProvider.donNetwork(type: .post,
                                            baseURL: Config.baseURL + "v1/ghost2",
                                            accessToken: accessToken,
                                            body: PostTransparencyRequestDTO(
                                                alarmTriggerType: alarmTriggerType,
                                                targetMemberId: targetMemberId,
                                                alarmTriggerId: alarmTriggerId,
                                                ghostReason: ghostReason
                                            ),
                                            pathVariables: ["":""])
            print("postDownTransparency result: \(result)")
            return result
        } catch {
            return nil
        }
    }
    
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
  
//    func postDownTransparency(accessToken: String, alarmTriggerType: String, targetMemberId: Int, alarmTriggerId: Int, ghostReason: String) async throws -> BaseResponse<EmptyResponse>? {
//        do {
//            let result: BaseResponse<EmptyResponse>? = try await
//            self.networkProvider.donNetwork(type: .post,
//                                            baseURL: Config.baseURL + "/ghost2",
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
