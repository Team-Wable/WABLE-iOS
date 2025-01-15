//
//  PopupViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/11/25.
//

import Foundation
import Combine

final class PopupViewModel {
    private let service: HomeAPI
    let data: HomeFeedDTO
    init(service: HomeAPI = HomeAPI.shared, data: HomeFeedDTO) {
        self.service = service
        self.data = data
    }
}

extension PopupViewModel: ViewModelType {
    struct Input {
        let deleteButtonDidTapSubject: AnyPublisher<Void, Never>
        let reportButtonDidTapSubject: AnyPublisher<Void, Never>
        let banButtonDidTapSubject: AnyPublisher<Void, Never>
        let ghostButtonDidTapSubject: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let dismissView: AnyPublisher<(HomeFeedDTO, PopupViewType), Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let dismissViewSubject = PassthroughSubject<(HomeFeedDTO, PopupViewType), Never>()
        input.deleteButtonDidTapSubject
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                
                return service.deleteFeed(contentID: data.contentID ?? -1)
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .sink { _ in
                let popupViewType = PopupViewType.delete
                dismissViewSubject.send((self.data, popupViewType))
            }
            .store(in: cancelBag)
        
        input.banButtonDidTapSubject
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                let memberID = data.memberID
                let triggerID = data.contentID ?? -1
                return service.postBan(
                    memberID: memberID,
                    triggerType: "content",
                    triggerID: triggerID
                )
                .mapWableNetworkError()
                .replaceError(with: nil)
                .compactMap { $0 }
                .eraseToAnyPublisher()
            }
            .sink { _ in
                let popupViewType = PopupViewType.ban
                dismissViewSubject.send((self.data, popupViewType))
            }
            .store(in: cancelBag)
        
        input.reportButtonDidTapSubject
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                let nickname = data.memberNickname
                let titleText = data.contentTitle ?? ""
                return service.postReport(nickname: nickname, relateText: titleText)
                .mapWableNetworkError()
                .replaceError(with: nil)
                .compactMap { $0 }
                .eraseToAnyPublisher()
            }
            .sink { _ in
                let popupViewType = PopupViewType.report
                dismissViewSubject.send((self.data, popupViewType))
            }
            .store(in: cancelBag)
        
        input.ghostButtonDidTapSubject
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                let memberID = data.memberID
                let triggerID = data.contentID ?? -1
                return service.postBeGhost(
                    triggerType: "contentGhost",
                    memberID: memberID,
                    triggerID: triggerID
                )
                .mapWableNetworkError()
                .replaceError(with: nil)
                .compactMap { $0 }
                .eraseToAnyPublisher()
            }
            .sink { _ in
                let popupViewType = PopupViewType.ghost
                dismissViewSubject.send((self.data, popupViewType))
            }
            .store(in: cancelBag)
        
        return Output(dismissView: dismissViewSubject.eraseToAnyPublisher())
    }
}
