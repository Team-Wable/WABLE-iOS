//
//  ViewitCoordinator.swift
//  Wable-iOS
//
//  Created by 김진웅 on 9/12/25.
//

import UIKit

final class ViewitCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = ViewitListViewModel(
            useCase: ViewitUseCaseImpl(),
            likeUseCase: LikeViewitUseCaseImpl(),
            reportUseCase: ReportViewitUseCaseImpl(),
            checkUserRoleUseCase: CheckUserRoleUseCaseImpl(
                repository: UserSessionRepositoryImpl(
                    userDefaults: UserDefaultsStorage(
                        jsonEncoder: JSONEncoder(),
                        jsonDecoder: JSONDecoder()
                    )
                )
            ),
            userSessionUseCase: FetchUserInformationUseCase(
                repository: UserSessionRepositoryImpl(
                    userDefaults: UserDefaultsStorage(
                        jsonEncoder: JSONEncoder(),
                        jsonDecoder: JSONDecoder()
                    )
                )
            )
        )
        let viewController = ViewitListViewController(viewModel: viewModel)
        
        viewController.showCreateViewit = { [weak self, weak viewController] in
            self?.showCreateViewit {
                viewController?.refresh()
            }
        }
        
        viewController.showProfile = { [weak self] id in
            self?.showProfile(for: id)
        }
        
        viewController.openURL = { [weak self] url in
            self?.openURL(url)
        }
        
        navigationController.pushViewController(viewController, animated: false)
    }
}

private extension ViewitCoordinator {
    func showCreateViewit(completion: @escaping (() -> Void)) {
        let useCase = CreateViewitUseCaseImpl()
        let viewController = CreateViewitViewController(viewModel: .init(useCase: useCase))
        viewController.onFinishCreateViewit = completion
        navigationController.present(viewController, animated: true)
    }
    
    func showProfile(for userID: Int?) {
        if let userID = userID {
            navigateToOtherProfile(for: userID)
        } else {
            showMyProfile()
        }
    }
    
    func navigateToOtherProfile(for userID: Int) {
        let otherProfileViewController = OtherProfileViewController(
            viewModel: .init(
                userID: userID,
                fetchUserProfileUseCase: FetchUserProfileUseCaseImpl(),
                checkUserRoleUseCase: CheckUserRoleUseCaseImpl(
                    repository: UserSessionRepositoryImpl(
                        userDefaults: UserDefaultsStorage(
                            jsonEncoder: JSONEncoder(),
                            jsonDecoder: JSONDecoder()
                        )
                    )
                )
            )
        )
        
        navigationController.pushViewController(otherProfileViewController, animated: true)
    }
    
    func showMyProfile() {
        navigationController.tabBarController?.selectedIndex = 4
    }
    
    func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            WableLogger.log("사이트를 열 수 없습니다: \(url.absoluteString)", for: .error)
        }
    }
}
