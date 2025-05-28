//
//  AppVersionRepository.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/29/25.
//

import Foundation

protocol AppVersionRepository {
    func fetchAppStoreVersion() async throws -> AppVersion
    func fetchCurrentVersion() -> AppVersion
}
