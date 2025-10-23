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

    private var lastItemID: Int = IntegerLiterals.initialCursor
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
                guard let self = self else { return .empty() }
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
                guard let lastItemID = items.last?.id else { return }
                self?.lastItemID = lastItemID
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
        return useCase
            .fetchCurationList(with: cursor)
            .map { [weak self] curations in curations.compactMap { self?.mapToCurationItem($0) }}
            .catch { error -> AnyPublisher<[CurationItem], Never> in
                WableLogger.log("Failed to fetch curations: \(error)", for: .error)
                return .just([])
            }
            .eraseToAnyPublisher()
    }
    
    func mapToCurationItem(_ curation: Curation) -> CurationItem {
        return CurationItem(
            id: curation.id,
            title: curation.title,
            createdAt: curation.time.elapsedText,
            siteName: extractSiteName(from: curation.siteURL),
            siteURL: curation.siteURL,
            thumbnailURL: curation.thumbnailURL
        )
    }

    func extractSiteName(from url: URL) -> String {
        guard let host = url.host?.lowercased() else { return url.absoluteString }
        
        let hostWithoutWWW = host.hasPrefix("www.")
            ? String(host.dropFirst(4))
            : host
        
        return mapHostToBrandName(hostWithoutWWW)
    }
    
    func mapHostToBrandName(_ host: String) -> String {
        if host == "youtu.be" || host.hasSuffix("youtube.com") {
            return "YouTube"
        } else if host.hasSuffix("instagram.com") {
            return "Instagram"
        } else if host.hasSuffix("twitter.com") || host.hasSuffix("x.com") {
            return "X"
        } else if host.hasSuffix("facebook.com") {
            return "Facebook"
        } else if host.hasSuffix("tiktok.com") {
            return "TikTok"
        } else if host == "naver.me" || host.hasSuffix("naver.com") {
            return "NAVER"
        } else if host.hasSuffix("daum.net") {
            return "Daum"
        } else if host == "goo.gl" || host.hasSuffix("google.com") {
            return "Google"
        } else if host.hasSuffix("kakao.com") {
            return "Kakao"
        } else {
            return host
        }
    }
}
