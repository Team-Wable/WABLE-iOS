//
//  ProfileViewItem.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Foundation

struct ProfileViewItem {
    var currentSegment: ProfileSegment = .content
    var profileInfo: UserProfile?
    var contentList: [UserContent] = []
    var commentList: [UserComment] = []
}
