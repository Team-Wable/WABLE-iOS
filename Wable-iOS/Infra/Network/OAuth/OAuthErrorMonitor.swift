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
    private var condition: Bool = false
    
    var isUnauthorized: Bool {
        get {
            queue.sync { condition }
        }
        set {
            queue.async(flags: .barrier) {
                self.condition = newValue
            }
        }
    }
    
    /// 서버로부터 응답을 받은 경우 호출되는 메서드
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        if let dataString = response.data?.toString,
           response.error?.responseCode == 401 && dataString.contains(WableError.unauthorizedToken.rawValue) {
            isUnauthorized = true
        }
    }
}


// MARK: - Extension

extension Data {
    var toString: String {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return "" }
        
        return dataString as String
    }
}
