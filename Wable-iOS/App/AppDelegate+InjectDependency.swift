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
        
        // MARK: - Viewit

        diContainer.register(for: ViewitRepository.self, object: ViewitRepositoryImpl())
        diContainer.register(for: URLPreviewRepository.self, object: URLPreviewRepositoryImpl())
    }
}
