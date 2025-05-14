//
//  AccountInfoViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

final class AccountInfoViewModel: ViewModelType {
    struct Input {
        let load: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let items: AnyPublisher<[AccountInfoCellItem], Never>
        let errorMessage: AnyPublisher<String, Never>
    }
    
    private let useCase: FetchAccountInfoUseCase
    
    init(useCase: FetchAccountInfoUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let errorSubject = PassthroughSubject<String, Never>()
        
        let itemsPublisher = input.load
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.useCase.execute()
                    .catch { error -> AnyPublisher<AccountInfo?, Never> in
                        errorSubject.send(error.localizedDescription)
                        return Just(nil).eraseToAnyPublisher()
                    }
            }
            .compactMap { $0 }
            .map { [weak self] accountInfo -> [AccountInfoCellItem] in
                guard let self else {
                    return []
                }
                
                return [
                    .init(title: "소셜 로그인", description: accountInfo.socialPlatform?.rawValue ?? ""),
                    .init(title: "버전 정보", description: accountInfo.version),
                    .init(title: "아이디", description: accountInfo.displayMemberID),
                    .init(title: "가입일", description: self.formatDate(accountInfo.createdDate ?? .now)),
                    .init(title: "이용약관", description: "자세히 보기", isUserInteractive: true),
                ]
            }
            .removeDuplicates()
            .asDriver()
        
        return Output(
            items: itemsPublisher,
            errorMessage: errorSubject.asDriver()
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
