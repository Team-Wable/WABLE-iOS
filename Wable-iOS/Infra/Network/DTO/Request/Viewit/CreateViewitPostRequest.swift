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
        let viewitImageURLString: String
        let viewitURLString: String
        let viewitTitle: String
        let viewitText: String
        let viewitName: String
        
        enum CodingKeys: String, CodingKey {
            case viewitImageURLString = "viewitImage"
            case viewitURLString = "viewitLink"
            case viewitTitle = "viewitTitle"
            case viewitText = "viewitText"
            case viewitName = "viewitName"
        }
    }
}
