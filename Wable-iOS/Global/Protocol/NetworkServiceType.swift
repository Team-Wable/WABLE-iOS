//
//  NetworkServiceType.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

protocol NetworkServiceType {
    func donMakeRequest(type: HttpMethod,
                        baseURL: String,
                        accessToken: String,
                        body: Encodable,
                        pathVariables: [String: String]) -> URLRequest
    
    func donNetwork<T: Decodable>(type: HttpMethod,
                                  baseURL: String,
                                  accessToken: String,
                                  body: Encodable,
                                  pathVariables: [String: String]) async throws -> T?
}

