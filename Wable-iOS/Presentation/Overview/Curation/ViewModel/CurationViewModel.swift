//
//  CurationViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/16/25.
//

import Foundation
import Combine

final class CurationViewModel {
    private let useCase: OverviewUseCase

    private var lastItemID: Int?
    private var hasMore: Bool = false
    private let processingQueue = DispatchQueue(label: "com.wable.curation.items", qos: .userInitiated)

    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private let itemsSubject = CurrentValueSubject<[CurationItem], Never>([])

    init(useCase: OverviewUseCase) {
        self.useCase = useCase
    }
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
                self?.fetchItems(cursor: IntegerLiterals.initialCursor) ?? Empty().eraseToAnyPublisher()
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
    func fetchItems(cursor: Int) -> AnyPublisher<[CurationItem], Never> {
        // 실제로는 여기서 UseCase나 Repository를 호출
        // 예: return curationUseCase.fetchCurationItems(cursor: cursor, pageSize: pageSize)
        // return useCase.fetchCurations(with: 0)
        
        // Mock 구현: 서버 요청 시뮬레이션
        return Future<[CurationItem], Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                promise(.success([]))
            }
        }
        .eraseToAnyPublisher()
    }
}
