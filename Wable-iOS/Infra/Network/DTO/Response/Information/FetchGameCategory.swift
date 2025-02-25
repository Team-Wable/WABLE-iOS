//
//  FetchGameCategory.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

extension DTO.Response {
    
    // MARK: - 경기 종목 데이터
    
    struct FetchGameCategory: Decodable {
        let lckGameType: String
    }
}
