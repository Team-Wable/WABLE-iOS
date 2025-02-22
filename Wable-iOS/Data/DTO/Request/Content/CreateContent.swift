//
//  CreateContent.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 게시물 작성하기

extension DTO.Request {
    struct CreateContent: Encodable {
        let text: Content
        let image: Data?
    }
    
    struct Content: Encodable {
        let contentTitle: String
        let contentText: String
    }
}
