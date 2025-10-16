//
//  CurationItem.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/16/25.
//

import Foundation

struct CurationItem: Hashable, Identifiable {
    let id: UUID = UUID()
    let time: String
    let title: String
    let source: String
    let thumbnailURL: URL?
}

extension CurationItem {
    static let mocks: [CurationItem] = [
        CurationItem(
            time: "1시간 전",
            title: "Ad ea excepteur nostrud sint commodo duis labore nostrud veniam cillum eu irure quis veniam dolor et",
            source: "Esse minim proident aliquip deserunt id magna sunt aliquip elit fugiat officia sunt consequat elit l",
            thumbnailURL: URL(string: "https://fastly.picsum.photos/id/176/343/220.jpg?hmac=h_eZSSP2OjzuGIVmDs1OZ_dYT3BzPbCC_QAnMZp5Sn8")
        ),
        CurationItem(
            time: "2시간 전",
            title: "Excepteur nulla sint commodo ea labore nostrud veniam commodo eu irure reprehenderit veniam dolor eu",
            source: "LMagna tempor aliquip elit id officia sunt aliquip elit fugiat officia sunt consequat eiusmod laborum",
            thumbnailURL: URL(string: "https://fastly.picsum.photos/id/176/343/220.jpg?hmac=h_eZSSP2OjzuGIVmDs1OZ_dYT3BzPbCC_QAnMZp5Sn8")
        ),
        CurationItem(
            time: "3시간 전",
            title: "Ea labore nulla voluptate commodo eu labore reprehenderit veniam commodo eu irure reprehenderit veni",
            source: "Labore sed voluptate dolore ex non reprehenderit cillum dolore ipsum non velit aute est ipsum qui ut",
            thumbnailURL: URL(string: "https://fastly.picsum.photos/id/176/343/220.jpg?hmac=h_eZSSP2OjzuGIVmDs1OZ_dYT3BzPbCC_QAnMZp5Sn8")
        )
    ]
}
