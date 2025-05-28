//
//  AppVersionRepositoryImpl.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/29/25.
//

import Foundation

final class AppVersionRepositoryImpl: AppVersionRepository {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchAppStoreVersion() async throws -> AppVersion {
        guard let url = URL(string: StringLiterals.URL.itunes) else {
            throw WableError.unknownError
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                  let results = jsonObject["results"] as? [[String: Any]],
                  let appStoreInfo = results.first,
                  let appStoreVersion = appStoreInfo["version"] as? String
            else {
                throw WableError.unknownError
            }
            
            return AppVersion(from: appStoreVersion)
        } catch let error as URLError {
            throw WableError.networkError
        } catch {
            throw error
        }
    }
    
    func fetchCurrentVersion() -> AppVersion {
        let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        
        return AppVersion(from: appVersionString)
    }
}

// MARK: - Mock

struct MockAppVersionRepository: AppVersionRepository {
    func fetchAppStoreVersion() async throws -> AppVersion {
        return AppVersion(from: "2.2.2")
    }
    
    func fetchCurrentVersion() -> AppVersion {
        return AppVersion(from: "2.2.0")
    }
}
