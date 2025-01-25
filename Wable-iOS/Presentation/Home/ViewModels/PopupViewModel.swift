//
//  PopupViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/11/25.
//

import Foundation
import Combine

final class PopupViewModel {
    
    let data: PopupModel
    
    private let service: HomeAPI

    init(service: HomeAPI = HomeAPI.shared, data: PopupModel) {
        self.service = service
        self.data = data
    }
}

extension PopupViewModel: ViewModelType {
    struct Input {
        let deleteButtonDidTap: AnyPublisher<Void, Never>
        let reportButtonDidTap: AnyPublisher<Void, Never>
        let banButtonDidTap: AnyPublisher<Void, Never>
        let ghostButtonDidTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let dismissView: AnyPublisher<PopupViewType, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let dismissViewSubject = PassthroughSubject<PopupViewType, Never>()
        input.deleteButtonDidTap
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                
                switch data.contentType {
                case .comment:
                    return service.deleteReply(commentID: data.triggerID)
                        .mapWableNetworkError()
                        .replaceError(with: nil)
                        .compactMap { $0 }
                        .eraseToAnyPublisher()
                case .content:
                    return service.deleteFeed(contentID: data.triggerID)
                        .mapWableNetworkError()
                        .replaceError(with: nil)
                        .compactMap { $0 }
                        .eraseToAnyPublisher()
                }
            }
            .sink { _ in
                let popupViewType = PopupViewType.delete
                dismissViewSubject.send(popupViewType)
            }
            .store(in: cancelBag)
        
        input.banButtonDidTap
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                let memberID = data.memberID
                let triggerID = data.triggerID
                return service.postBan(
                    memberID: memberID,
                    triggerType: data.contentType.rawValue,
                    triggerID: triggerID
                )
                .mapWableNetworkError()
                .replaceError(with: nil)
                .compactMap { $0 }
                .eraseToAnyPublisher()
            }
            .sink { _ in
                let popupViewType = PopupViewType.ban
                dismissViewSubject.send(popupViewType)
            }
            .store(in: cancelBag)
        
        input.reportButtonDidTap
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                let nickname = data.nickname
                let titleText = data.relatedText
                return service.postReport(
                    nickname: nickname,
                    relateText: titleText
                )
                .mapWableNetworkError()
                .replaceError(with: nil)
                .compactMap { $0 }
                .eraseToAnyPublisher()
            }
            .sink { _ in
                let popupViewType = PopupViewType.report
                dismissViewSubject.send(popupViewType)
            }
            .store(in: cancelBag)
        
        input.ghostButtonDidTap
            .flatMap { [weak self] _ -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(EmptyDTO()).eraseToAnyPublisher()
                }
                let memberID = data.memberID
                let triggerID = data.triggerID
                
                switch data.contentType {
                case .comment:
                    return service.postBeGhost(
                        triggerType: "commentGhost",
                        memberID: memberID,
                        triggerID: triggerID
                    )
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .compactMap { $0 }
                    .eraseToAnyPublisher()
                case .content:
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
            }
            .sink { _ in
                let popupViewType = PopupViewType.ghost
                dismissViewSubject.send(popupViewType)
            }
            .store(in: cancelBag)
        
        return Output(dismissView: dismissViewSubject.eraseToAnyPublisher())
    }
}
