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
        
        diContainer.register(for: ReportRepository.self) { config in
            switch config {
            case .debug:
                return MockReportRepository()
            case .release:
                return ReportRepositoryImpl()
            }
        }
        
        // MARK: - Viewit

        diContainer.register(for: ViewitRepository.self) { config in
            switch config {
            case .debug:
                return MockViewitRepository()
            case .release:
                return ViewitRepositoryImpl()
            }
        }
        
        diContainer.register(for: URLPreviewRepository.self, object: URLPreviewRepositoryImpl())
        
        // MARK: - Comment
        
        diContainer.register(for: CommentRepository.self) { config in
            switch config {
            case .debug:
                return MockCommentRepository()
            case .release:
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

        diContainer.register(for: GhostRepository.self) { config in
            return GhostRepositoryImpl()
        }
    }
}
