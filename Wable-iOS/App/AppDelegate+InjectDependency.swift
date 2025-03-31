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
        diContainer.register(for: InformationRepository.self, object: InformationRepositoryImpl())
    }
}
