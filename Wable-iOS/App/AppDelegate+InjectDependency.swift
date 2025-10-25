//
//  AppDelegate+InjectDependency.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/29/25.
//

import Foundation

extension AppDelegate {
    var diContainer: AppDIContainer { AppDIContainer.shared }
    
    func injectDependency() {
        
        // MARK: - UserSession
        
        diContainer.register(
            for: UserSessionRepository.self,
            object: UserSessionRepositoryImpl(userDefaults: UserDefaultsStorage())
        )
        
        // MARK: - Account
        
        diContainer.register(for: AccountRepository.self, object: AccountRepositoryImpl())

        
        // MARK: - Login
        
        diContainer.register(for: LoginRepository.self, object: LoginRepositoryImpl())
        diContainer.register(for: TokenStorage.self, object: TokenStorage(keyChainStorage: KeychainStorage()))

        // MARK: - Overview
        
        diContainer.register(for: InformationRepository.self) { env in
            switch env {
            case .mock: MockInformationRepository()
            case .production: InformationRepositoryImpl()
            }
        }
        
        
        // MARK: - Report
        
        diContainer.register(for: ReportRepository.self) { env in
            switch env {
            case .mock: MockReportRepository()
            case .production: ReportRepositoryImpl()
            }
        }
        
        // MARK: - Viewit

        diContainer.register(for: ViewitRepository.self) { env in
            switch env {
            case .mock: MockViewitRepository()
            case .production: ViewitRepositoryImpl()
            }
        }
        
        diContainer.register(for: URLPreviewRepository.self, object: URLPreviewRepositoryImpl())
        
        // MARK: - Comment
        
        diContainer.register(for: CommentRepository.self) { env in
            switch env {
            case .mock: MockCommentRepository()
            case .production: CommentRepositoryImpl()
            }
        }
        diContainer.register(for: CommentLikedRepository.self, object: CommentLikedRepositoryImpl())
        
        // MARK: - Content

        diContainer.register(for: ContentRepository.self, object: ContentRepositoryImpl())
        diContainer.register(for: ContentLikedRepository.self, object: ContentLikedRepositoryImpl())
        
        // MARK: - Profile

        diContainer.register(for: ProfileRepository.self, object: ProfileRepositoryImpl())
        
        // MARK: - Ghost

        diContainer.register(for: GhostRepository.self) { env in
            return GhostRepositoryImpl()
        }
        
        // MARK: - AppVersion
        
        diContainer.register(for: AppVersionRepository.self) { env in
            switch env {
            case .mock: MockAppVersionRepository()
            case .production: AppVersionRepositoryImpl()
            }
        }
        
        diContainer.register(for: UpdateAlertPolicyRepository.self) { env in
            switch env {
            case .mock: MockUpdateAlertPolicyRepository()
            case .production: UpdateAlertPolicyRepositoryImpl()
            }
        }
        
        // MARK: - Community

        diContainer.register(for: CommunityRepository.self) { env in
            switch env {
            case .mock: MockCommunityRepository()
            case .production: CommunityRepositoryImpl()
            }
        }

        // MARK: - Quiz

        diContainer.register(for: QuizRepository.self) { env in
            switch env {
            case .mock: MockQuizRepository()
            case .production: QuizRepositoryImpl()
            }
        }
    }
}
