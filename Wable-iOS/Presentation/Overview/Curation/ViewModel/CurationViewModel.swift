//
//  CurationViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/16/25.
//

import Foundation
import Combine

final class CurationViewModel {

    private var lastItemID: UUID?

    private(set) var hasMore: Bool = false

    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let itemsSubject = CurrentValueSubject<[CurationItem], Never>([])
}

extension CurationViewModel: ViewModelType {
    struct Input {
        let load: AnyPublisher<Void, Never>
        let loadMore: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let items: AnyPublisher<[CurationItem], Never>
        let isLoading: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        input.load
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
            })
            .flatMap { [weak self] _ -> AnyPublisher<[CurationItem], Never> in
                self?.fetchItems(cursor: nil) ?? Empty().eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] _ in 
                self?.isLoadingSubject.send(false)
            })
            .sink { [weak self] newItems in self?.itemsSubject.send(newItems) }
            .store(in: cancelBag)

        input.loadMore
            .flatMap { [weak self] _ -> AnyPublisher<[CurationItem], Never> in
                guard let self = self, self.hasMore, !self.isLoadingSubject.value else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.fetchItems(cursor: self.lastItemID)
            }
            .sink { [weak self] newItems in
                guard let self = self, !newItems.isEmpty else {
                    self?.hasMore = false
                    return
                }
                self.itemsSubject.value.append(contentsOf: newItems)
            }
            .store(in: cancelBag)
        
        let items = itemsSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] items in
                self?.lastItemID = items.last?.id
                self?.hasMore = items.count >= IntegerLiterals.defaultCountPerPage
            })
            .eraseToAnyPublisher()

        let isLoading = isLoadingSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(
            items: items,
            isLoading: isLoading
        )
    }
}

// MARK: - Helper Methods

private extension CurationViewModel {
    func fetchItems(cursor: UUID?) -> AnyPublisher<[CurationItem], Never> {
        // 실제로는 여기서 UseCase나 Repository를 호출
        // 예: return curationUseCase.fetchCurationItems(cursor: cursor, pageSize: pageSize)
        
        // Mock 구현: 서버 요청 시뮬레이션
        return Future<[CurationItem], Never> { [weak self] promise in
            guard let self = self else {
                promise(.success([]))
                return
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                let currentItemCount = self.itemsSubject.value.count
                let newItems = self.generateMockItems(
                    cursor: cursor,
                    pageSize: IntegerLiterals.defaultCountPerPage,
                    startIndex: cursor == nil ? 0 : currentItemCount
                )
                promise(.success(newItems))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func generateMockItems(cursor: UUID?, pageSize: Int, startIndex: Int) -> [CurationItem] {
        // 총 45개까지만 있다고 가정
        let remainingItems = max(0, 45 - startIndex)
        let itemsToGenerate = min(pageSize, remainingItems)
        
        return (0..<itemsToGenerate).map { index in
            CurationItem(
                time: "5분 전",
                title: "영상 제목입니다 (아이템 \(startIndex + index + 1))",
                source: "네이버",
                thumbnailURL: nil
            )
        }
    }
}
