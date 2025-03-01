//
//  OAuthErrorMonitor.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/27/25.
//


import Foundation

import Alamofire

final class OAuthErrorMonitor: EventMonitor {
    let queue = DispatchQueue(label: "OAuthErrorMonitorQueue", attributes: .concurrent)
    private static var condition = false
 
    var isUnauthorized: Bool {
        get {
            queue.sync { OAuthErrorMonitor.condition }
        }
        set {
            queue.async(flags: .barrier) {
                OAuthErrorMonitor.condition = newValue
            }
        }
    }
    
    /// 서버로부터 응답을 받은 경우 호출되는 메서드
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        
        if let data = response.data,
           let dataString = String.init(data: data, encoding: .utf8),
           response.error?.responseCode == 401 && dataString.contains(WableError.unauthorizedToken.rawValue) {
            isUnauthorized = true
        }
    }
}
