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
    }
}
