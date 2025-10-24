//
//  FetchLatestCurationID.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/24/25.
//

import Foundation

extension DTO.Response {

    // MARK: - 최신 큐레이션 번호 조회

    struct FetchLatestCurationID: Decodable {
        let latestCurationID: Int

        enum CodingKeys: String, CodingKey {
            case latestCurationID = "curationId"
        }
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> 25089b3 ([Feat] #300 - 최신 큐레이션 번호 조회 API 구성)
