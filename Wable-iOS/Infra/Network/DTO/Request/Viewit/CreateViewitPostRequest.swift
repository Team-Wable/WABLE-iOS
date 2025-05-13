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
        let viewitImage: String
        let viewitLink: String
        let viewitTitle: String
        let viewitText: String
        let viewitName: String
    }
}
