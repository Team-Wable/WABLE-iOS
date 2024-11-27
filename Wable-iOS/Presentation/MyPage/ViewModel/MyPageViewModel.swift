//
//  MyPageViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/19/24.
//

import Combine
import Foundation

final class MyPageViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let networkProvider: NetworkServiceType
    private var getProfileData = PassthroughSubject<MypageProfileResponseDTO, Never>()
    private var getContentData = PassthroughSubject<[HomeFeedDTO], Never>()
    private var getCommentData = PassthroughSubject<[MyPageMemberCommentResponseDTO], Never>()
    let replyCellDidTapped = PassthroughSubject<Int,Never>()
    let feedDetailTopInfoDTO = PassthroughSubject<(HomeFeedDTO, Int), Never>()
    
    var myPageProfileData: [MypageProfileResponseDTO] = []
    var myPageContentData: [HomeFeedDTO] = []
    var myPageContentDatas: [HomeFeedDTO] = []
    
    var myPageCommentData: [MyPageMemberCommentResponseDTO] = []
    var myPageCommentDatas: [MyPageMemberCommentResponseDTO] = []
    
    private var memberId: Int = 0
    var contentCursor: Int = -1
    var commentCursor: Int = -1
    
    struct Input {
        let viewUpdate: AnyPublisher<(Int,Int,Int,Int), Never>
    }
    
    struct Output {
        let getProfileData: PassthroughSubject<MypageProfileResponseDTO, Never>
        let getContentData: PassthroughSubject<[HomeFeedDTO], Never>
        let getCommentData: PassthroughSubject<[MyPageMemberCommentResponseDTO], Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.viewUpdate
            .sink { [self] value in
                if value.0 == 1 {
                    // 유저 프로필 조회 API
                    Task {
                        do {
                            if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                                let profileResult = try await self.getProfileInfoAPI(accessToken: accessToken, memberId: value.1)
                                if let data = profileResult?.data {
//                                    print("data: \(data)")
                                    self.myPageProfileData.append(data)
                                    self.getProfileData.send(data)
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                    // 유저에 해당하는 게시글 리스트 조회
                    Task {
                        do {
                            if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                                let contentResult = try await self.getMemberContentAPI(accessToken: accessToken, memberId: value.1, contentCursor: value.3)
                                
                                if let data = contentResult?.data {
                                    self.getContentData.send(self.myPageContentDatas)
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                    // 유저에 해당하는 답글 리스트 조회
                    Task {
                        do {
                            if let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") {
                                let commentResult = try await self.getMemberCommentAPI(accessToken: accessToken, memberId: value.1, commentCursor: value.2)
                                
                                if let data = commentResult?.data {
                                    self.getCommentData.send(self.myPageCommentDatas)
                                }
                                
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            .store(in: self.cancelBag)
        
        return Output(getProfileData: getProfileData,
                      getContentData: getContentData,
                      getCommentData: getCommentData)
    }
    
    private func transform() {
        replyCellDidTapped
            .sink { [weak self] contentID in
                NotificationAPI.shared.getFeedTopInfo(contentID: contentID) { result in
                    guard let result = self?.validateResult(result) as? HomeFeedDTO else { return }
                    self?.feedDetailTopInfoDTO.send((result, contentID))
                }
            }
            .store(in: cancelBag)    }
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
        transform()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyPageViewModel {
    private func getProfileInfoAPI(accessToken: String, memberId: Int) async throws -> BaseResponse<MypageProfileResponseDTO>? {
        do {
            let result: BaseResponse<MypageProfileResponseDTO>? = try await self.networkProvider.donNetwork(
                type: .get,
                baseURL: Config.baseURL + "v1/viewmember/\(memberId)",
                accessToken: accessToken,
                body: EmptyBody(),
                pathVariables: ["":""])
            UserDefaults.standard.set(result?.data?.memberGhost ?? 0, forKey: "memberGhost")
            return result
        } catch {
            return nil
        }
    }
    
    private func getMemberContentAPI(accessToken: String, memberId: Int, contentCursor: Int) async throws -> BaseResponse<[HomeFeedDTO]>? {
        do {
            let result: BaseResponse<[HomeFeedDTO]>? = try await self.networkProvider.donNetwork(
                type: .get,
                baseURL: Config.baseURL + "v3/member/\(memberId)/contents",
                accessToken: accessToken,
                body: EmptyBody(),
                pathVariables:["cursor":"\(contentCursor)"])
            if let data = result?.data {
                if contentCursor == -1 {
                    self.myPageContentDatas = []
                    
                    var tempArrayData: [HomeFeedDTO] = []
                    
                    for content in data {
                        tempArrayData.append(content)
                    }
                    self.myPageContentData = tempArrayData
                    myPageContentDatas.append(contentsOf: myPageContentData)
                } else {
                    var tempArrayData: [HomeFeedDTO] = []
                    
                    if data.isEmpty {
                        self.contentCursor = -1
                    } else {
                        for content in data {
                            tempArrayData.append(content)
                        }
                        self.myPageContentData = tempArrayData
                        myPageContentDatas.append(contentsOf: myPageContentData)
                    }
                }
            }
            return result
        } catch {
            return nil
        }
    }
    
    private func getMemberCommentAPI(accessToken: String, memberId: Int, commentCursor: Int) async throws -> BaseResponse<[MyPageMemberCommentResponseDTO]>? {
        do {
            let result: BaseResponse<[MyPageMemberCommentResponseDTO]>? = try await self.networkProvider.donNetwork(
                type: .get,
                baseURL: Config.baseURL + "v3/member/\(memberId)/comments",
                accessToken: accessToken,
                body: EmptyBody(),
                pathVariables:["cursor":"\(commentCursor)"])
            if let data = result?.data {
                print("commentCursor: \(commentCursor)")
                print("data: \(data)")
                if commentCursor == -1 {
                    self.myPageCommentDatas = []
                    
                    var tempArrayData: [MyPageMemberCommentResponseDTO] = []
                    
                    for comment in data {
                        tempArrayData.append(comment)
                    }
                    self.myPageCommentData = tempArrayData
                    myPageCommentDatas.append(contentsOf: myPageCommentData)
                } else {
                    var tempArrayData: [MyPageMemberCommentResponseDTO] = []
                    
                    for comment in data {
                        tempArrayData.append(comment)
                    }
                    self.myPageCommentData = tempArrayData
                    myPageCommentDatas.append(contentsOf: myPageCommentData)
                }
            }
            return result
        } catch {
            return nil
        }
    }
    
    private func validateResult(_ result: NetworkResult<Any>) -> Any?{
        switch result{
        case .success(let data):
            print("성공했습니다.")
            print("⭐️⭐️⭐️⭐️⭐️⭐️")
            print(data)
            return data
        case .requestErr(let message):
            print(message)
        case .pathErr:
            print("path 혹은 method 오류입니다.🤯")
        case .serverErr:
            print("서버 내 오류입니다.🎯")
        case .networkFail:
            print("네트워크가 불안정합니다.💡")
        case .decodedErr:
            print("디코딩 오류가 발생했습니다.🕹️")
        case .authorizationFail(_):
            print("인증 오류가 발생했습니다. 다시 로그인해주세요🔐")
        }
        return nil
    }
}
