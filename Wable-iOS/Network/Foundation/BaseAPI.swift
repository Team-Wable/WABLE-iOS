//
//  BaseAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import Foundation

import Moya

class BaseAPI {
    public func judgeStatus<T: Codable>(by statusCode: Int,
                                        _ data: Data,
                                        _ object: T.Type) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(SuccessResponse<T>.self, from: data)
        else {
            print("👻👻👻 디코딩 실패입니다. 명세서를 다시 보심이 어떠한지? 👻👻👻")
            return .decodedErr
        }

        // 엑세스토큰 만료되면 뜨는 에러코드 따로 분리
        switch statusCode {
        case 200..<205:
            guard decodedData.data != nil else {
                print("⛔️ \(self)에서 디코딩 오류가 발생했습니다 ⛔️")
                return .decodedErr
            }
//            print("👻👻👻 디코딩 성공했습니다! 추카추카 👻👻👻")
            return .success(decodedData.data as Any)
        case 401:
            return .authorizationFail((decodedData.message, decodedData.status))
        case 400..<500:
            return .requestErr(decodedData.message ?? "요청에러")
        case 500:
            return .serverErr
        default:
            return .networkFail
        }
    }

    // fetch 같은 것들은 data 응답이 따로 없기 때문에 여기서 처리
    private func judgeSimpleResponseStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(ErrorResponse.self, from: data)
        else {
            print("⛔️ \(self)에서 디코딩 오류가 발생했습니다 ⛔️")
            return .decodedErr
        }
        
        /// 에러코드 관련 명세 나오면 더 자세하게 분류
        switch statusCode {
        case 200, 201:
            return .success(decodedData)
        case 401:
            return .authorizationFail((decodedData.message, decodedData.status))
        case 400..<500:
            return .requestErr(decodedData.message ?? "요청에러")
        case 500:
            return .serverErr
        default:
            return .networkFail
        }
    }


    public func disposeNetwork<T: Codable>(_ result: Result<Response, MoyaError>,
                                           dataModel: T.Type,
                                           completion: @escaping (NetworkResult<Any>) -> Void) {
//        print("📍\(#function) 에서 result \(result)")
        switch result{
        case .success(let response):
            let statusCode = response.statusCode
            let data = response.data

            if statusCode == 200 || statusCode == 201 {
                let networkResult = self.judgeStatus(by: statusCode, data, dataModel.self)
                completion(networkResult)
            } else {  // 400,500같은 에러에는 data가 없기떄문에 여기서 한번 걸러줌
                let networkResult = self.judgeSimpleResponseStatus(by: statusCode, data)
                completion(networkResult)
            }

        case .failure(let err):
            print(err)
            print("👻👻👻 네트워크 오류 혹은 endpoint 작성이 잘못되었습니다 확인해보세요! 👻👻👻")
        }
    }
}

extension BaseAPI {
    enum WableNetworkError: Error {
        /// 요청 오류
        case requestError(String)
        /// 디코딩 오류
        case decodedError(String)
        /// 경로 오류
        case pathError
        /// 서버 내부 오류
        case serverError
        /// 네트워크 실패
        case networkFail
        /// 토큰 인증 오류
        case authorizationFail(String, Int)
        /// 알 수 없는 에러
        case unknownError(String)
    }
    
    // TODO: 프로토콜로 추상화 가능
    
    func parseResponse<T: Codable>(statusCode: Int, data: Data) throws -> T? {
        let baseResponse = try decodeResponse(with: BaseResponse<T>.self, from: data)
        return try handleStatusCode(statusCode, with: baseResponse)
    }
    
    private func decodeResponse<T:Codable>(with baseResonse: BaseResponse<T>.Type, from data: Data) throws -> BaseResponse<T> {
        do {
            let decodedData = try JSONDecoder().decode(baseResonse, from: data)
            return decodedData
        } catch {
            throw WableNetworkError.decodedError("\(error)")
        }
    }
    
    private func handleStatusCode<T: Codable>(_ statusCode: Int, with baseResponse: BaseResponse<T>) throws -> T? {
        switch statusCode {
        case 200..<300:
            return baseResponse.data
        case 401:
            throw WableNetworkError.authorizationFail(baseResponse.message, baseResponse.status)
        case 400..<500:
            throw WableNetworkError.requestError(baseResponse.message)
        case 500...:
            throw WableNetworkError.serverError
        default:
            throw WableNetworkError.networkFail
        }
    }
}

extension BaseAPI.WableNetworkError: CustomStringConvertible {
    var description: String {
        switch self {
        case .requestError(let message):
            return "‼️ 요청 에러 발생: \(message) ‼️"
        case .decodedError(let message):
            return "‼️ 디코딩 에러 발생: \(message) ‼️"
        case .pathError:
            return "‼️ 경로 에러 발생 ‼️"
        case .serverError:
            return "‼️ 서버 내부 에러 발생 ‼️"
        case .networkFail:
            return "‼️ 네트워크 실패! ‼️"
        case .authorizationFail(_, _):
            return "‼️ 권한이 없네요. ‼️"
        case .unknownError(let message):
            return "‼️ 알 수 없는 에러: \(message) ‼️"
        }
    }
}
