//
//  AccountInfoViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

final class AccountInfoViewModel {
    @Published private(set) var items: [AccountInfoCellItem] = []
    @Published private(set) var errorMessage: String?
    
    @Injected private var appVersionRepository: AppVersionRepository
    
    private let useCase: FetchAccountInfoUseCase
    
    init(useCase: FetchAccountInfoUseCase) {
        self.useCase = useCase
    }
    
    func viewDidLoad() {
        let currentAppVersion = appVersionRepository.fetchCurrentVersion().description
        Task {
            do {
                let accountInfo = try await useCase.execute()
                items = [
                    .init(title: "소셜 로그인", description: accountInfo.socialPlatform?.rawValue ?? ""),
                    .init(title: "버전 정보", description: currentAppVersion),
                    .init(title: "아이디", description: accountInfo.displayMemberID),
                    .init(title: "가입일", description: formatDate(accountInfo.createdDate ?? .now)),
                    .init(title: "이용약관", description: "자세히 보기", isUserInteractive: true)
                ]
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
