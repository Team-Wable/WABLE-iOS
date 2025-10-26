//
//  ProfileCoordinator.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/25/25.
//

import UIKit
import SafariServices

final class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    var navigationController: UINavigationController

    var onFinish: (() -> Void)?
    var onLogout: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = MyProfileViewModel(
            userinformationUseCase: FetchUserInformationUseCase(
                repository: UserSessionRepositoryImpl(
                    userDefaults: UserDefaultsStorage(
                        jsonEncoder: JSONEncoder(),
                        jsonDecoder: JSONDecoder()
                    )
                )
            ),
            fetchUserProfileUseCase: FetchUserProfileUseCaseImpl(),
            removeUserSessionUseCase: RemoveUserSessionUseCaseImpl()
        )

        let viewController = MyProfileViewController(viewModel: viewModel)

        viewController.onLogout = { [weak self] in
            self?.onLogout?()
        }

        viewController.showAccountInfo = { [weak self] in
            self?.navigateToAccountInfo()
        }

        viewController.showAlarmSetting = { [weak self] in
            self?.navigateToAlarmSetting()
        }

        viewController.showWritePost = { [weak self] in
            self?.navigateToWritePost()
        }

        viewController.showHomeDetail = { [weak self] contentID in
            self?.navigateToHomeDetail(contentID: contentID)
        }

        viewController.showPhotoDetail = { [weak self] image in
            self?.navigateToPhotoDetail(image: image)
        }

        viewController.openURL = { [weak self] url in
            self?.presentURL(url)
        }

        viewController.showProfileEdit = { [weak self] userID in
            self?.navigateToProfileEdit(userID: userID)
        }

        navigationController.pushViewController(viewController, animated: false)
    }
}

private extension ProfileCoordinator {
    func navigateToAccountInfo() {
        let viewModel = AccountInfoViewModel(useCase: FetchAccountInfoUseCaseImpl())
        let viewController = AccountInfoViewController(viewModel: viewModel)
        viewController.showWithdrawalReason = { [weak self] in
            self?.navigateToWithdrawalReason()
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    func navigateToAlarmSetting() {
        let viewModel = AlarmSettingViewModel()
        let viewController = AlarmSettingViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func navigateToWritePost() {
        let viewController = WritePostViewController(
            viewModel: WritePostViewModel(
                createContentUseCase: CreateContentUseCase(
                    repository: ContentRepositoryImpl()
                )
            )
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    func navigateToHomeDetail(contentID: Int) {
        let viewController = HomeDetailViewController(
            viewModel: HomeDetailViewModel(
                contentID: contentID,
                fetchContentInfoUseCase: FetchContentInfoUseCase(repository: ContentRepositoryImpl()),
                fetchContentCommentListUseCase: FetchContentCommentListUseCase(repository: CommentRepositoryImpl()),
                createCommentUseCase: CreateCommentUseCase(repository: CommentRepositoryImpl()),
                deleteCommentUseCase: DeleteCommentUseCase(repository: CommentRepositoryImpl()),
                createContentLikedUseCase: CreateContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
                deleteContentLikedUseCase: DeleteContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
                createCommentLikedUseCase: CreateCommentLikedUseCase(repository: CommentLikedRepositoryImpl()),
                deleteCommentLikedUseCase: DeleteCommentLikedUseCase(repository: CommentLikedRepositoryImpl()),
                fetchUserInformationUseCase: FetchUserInformationUseCase(
                    repository: UserSessionRepositoryImpl(
                        userDefaults: UserDefaultsStorage(
                            jsonEncoder: JSONEncoder(),
                            jsonDecoder: JSONDecoder()
                        )
                    )
                ),
                fetchGhostUseCase: FetchGhostUseCase(repository: GhostRepositoryImpl()),
                createReportUseCase: CreateReportUseCase(repository: ReportRepositoryImpl()),
                createBannedUseCase: CreateBannedUseCase(repository: ReportRepositoryImpl()),
                deleteContentUseCase: DeleteContentUseCase(repository: ContentRepositoryImpl())
            ),
            cancelBag: CancelBag()
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    func navigateToPhotoDetail(image: UIImage) {
        let photoDetailViewController = PhotoDetailViewController(image: image)
        navigationController.pushViewController(photoDetailViewController, animated: true)
    }

    func presentURL(_ url: URL) {
        let safari = SFSafariViewController(url: url)
        navigationController.present(safari, animated: true)
    }

    func navigateToProfileEdit(userID: Int) {
        let vc = ProfileEditViewController(userID: userID)
        navigationController.pushViewController(vc, animated: true)
    }

    func navigateToWithdrawalReason() {
        let viewController = WithdrawalReasonViewController()
        viewController.showWithdrawalGuide = { [weak self] selectedReasons in
            self?.navigateToWithdrawalGuide(selectedReasons: selectedReasons)
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    func navigateToWithdrawalGuide(selectedReasons: [WithdrawalReason]) {
        let viewModel = WithdrawalGuideViewModel(
            selectedReasons: selectedReasons,
            withdrawUseCase: WithdrawUseCaseImpl()
        )
        let viewController = WithdrawalGuideViewController(viewModel: viewModel)
        viewController.onWithdraw = { [weak self] in
            self?.onLogout?()
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
