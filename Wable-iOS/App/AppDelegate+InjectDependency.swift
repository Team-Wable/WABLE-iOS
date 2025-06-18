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
        
        // MARK: - Overview

        diContainer.register(for: InformationRepository.self, object: InformationRepositoryImpl())
        
        
        // MARK: - Report
        
        diContainer.register(for: ReportRepository.self) { env in
            switch env {
            case .mock:
                return MockReportRepository()
            case .production:
                return ReportRepositoryImpl()
            }
        }
        
        // MARK: - Viewit

        diContainer.register(for: ViewitRepository.self) { env in
            switch env {
            case .mock:
                return MockViewitRepository()
            case .production:
                return ViewitRepositoryImpl()
            }
        }
        
        diContainer.register(for: URLPreviewRepository.self, object: URLPreviewRepositoryImpl())
        
        // MARK: - Comment
        
        diContainer.register(for: CommentRepository.self) { env in
            switch env {
            case .mock:
                return MockCommentRepository()
            case .production:
                return CommentRepositoryImpl()
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
            case .mock:
                return MockAppVersionRepository()
            case .production:
                return AppVersionRepositoryImpl()
            }
        }
        
        diContainer.register(for: UpdateAlertPolicyRepository.self) { env in
            switch env {
            case .mock:
                return MockUpdateAlertPolicyRepository()
            case .production:
                return UpdateAlertPolicyRepositoryImpl()
        
        // MARK: - Community
        
        diContainer.register(for: CommunityRepository.self) { env in
            switch env {
            case .mock: MockCommunityRepository()
            case .production: CommunityRepositoryImpl()
            }
        }
    }
}
