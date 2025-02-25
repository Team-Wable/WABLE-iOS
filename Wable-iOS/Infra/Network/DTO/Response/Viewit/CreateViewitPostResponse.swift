//
//  CreateViewitPost.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/20/25.
//


import Foundation

// MARK: - 뷰잇 게시물 작성

extension DTO.Response {
    struct CreateViewitPost: Decodable {
        let viewitImage: String
        let viewitLink: String
        let viewitTitle: String
        let viewitText: String
    }
}
