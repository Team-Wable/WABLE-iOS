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
            print("👻👻👻 디코딩 성공했습니다! 추카추카 👻👻👻")
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
        print("📍\(#function) 에서 result \(result)")
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
