//
//  CreateViewitPost.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Foundation

// MARK: - 뷰잇 게시물 작성

extension DTO.Request {
    struct CreateViewitPost: Encodable {
        let viewitImageURL: String
        let viewitURL: String
        let viewitTitle: String
        let viewitText: String
        
        enum CreateViewitPost: String, CodingKey {
            case viewitImageURL = "viewitImage"
            case viewitURL = "viewitLink"
            case viewitTitle, viewitText
        }
    }
}
