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
    private var hasMore: Bool = false
    private let processingQueue = DispatchQueue(label: "com.wable.curation.items", qos: .userInitiated)

    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
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
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        input.load
            .handleEvents(receiveOutput: { [weak self] _ in self?.isLoadingSubject.send(true) })
            .flatMap { [weak self] _ -> AnyPublisher<[CurationItem], Never> in
                self?.fetchItems(cursor: nil) ?? Empty().eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] _ in self?.isLoadingSubject.send(false) })
            .sink { [weak self] newItems in self?.updateItemsReplacing(with: newItems) }
            .store(in: cancelBag)

        input.loadMore
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { [weak self] _ in self?.canTriggerLoadMore() ?? false }
            .handleEvents(receiveOutput: { [weak self] _ in self?.isLoadingMoreSubject.send(true) })
            .flatMap { [weak self] _ -> AnyPublisher<[CurationItem], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.fetchItems(cursor: self.lastItemID)
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in self?.isLoadingMoreSubject.send(false) })
            .sink { [weak self] newItems in self?.handleLoadMoreResponse(newItems) }
            .store(in: cancelBag)
        
        let items = itemsSubject
            .receive(on: processingQueue)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] items in
                self?.lastItemID = items.last?.id
            })
            .eraseToAnyPublisher()

        let isLoading = isLoadingSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        let isLoadingMore = isLoadingMoreSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(
            items: items,
            isLoading: isLoading,
            isLoadingMore: isLoadingMore
        )
    }
}

// MARK: - Helper Methods

private extension CurationViewModel {
    func canTriggerLoadMore() -> Bool {
        hasMore && !isLoadingSubject.value && !isLoadingMoreSubject.value
    }

    func updateItemsReplacing(with newItems: [CurationItem]) {
        updatePaginationState(after: newItems)
        itemsSubject.send(newItems)
    }

    func appendItems(_ newItems: [CurationItem]) {
        var current = itemsSubject.value
        current.append(contentsOf: newItems)
        itemsSubject.send(current)
    }

    func updatePaginationState(after newItems: [CurationItem]) {
        hasMore = newItems.count >= IntegerLiterals.defaultCountPerPage
    }

    func handleLoadMoreResponse(_ newItems: [CurationItem]) {
        guard !newItems.isEmpty else {
            hasMore = false
            return
        }
        updatePaginationState(after: newItems)
        appendItems(newItems)
    }
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
                thumbnailURL: URL(string: "https://fastly.picsum.photos/id/176/343/220.jpg?hmac=h_eZSSP2OjzuGIVmDs1OZ_dYT3BzPbCC_QAnMZp5Sn8")
            )
        }
    }
}
