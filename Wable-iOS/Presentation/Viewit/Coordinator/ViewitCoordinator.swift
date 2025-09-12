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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vm = ViewitListViewModel(
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
        let vc = ViewitListViewController(viewModel: vm)
        
        vc.showCreateViewit = { [weak self, weak vc] in
            self?.showCreateViewit {
                vc?.refresh()
            }
        }
        
        vc.showProfile = { [weak self] id in
            self?.showProfile(for: id)
        }
        
        vc.openURL = { [weak self] url in
            self?.openURL(url)
        }
        
        navigationController.pushViewController(vc, animated: false)
    }
}

private extension ViewitCoordinator {
    func showCreateViewit(completion: @escaping (() -> Void)) {
        let useCase = CreateViewitUseCaseImpl()
        let vc = CreateViewitViewController(viewModel: .init(useCase: useCase))
        vc.onFinishCreateViewit = completion
        navigationController.present(vc, animated: true)
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
