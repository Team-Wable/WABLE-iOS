//
//  ViewitListViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/10/25.
//

import Combine
import Foundation

final class ViewitListViewModel {
    private let useCase: ViewitUseCase
    
    init(useCase: ViewitUseCase) {
        self.useCase = useCase
    }
}

extension ViewitListViewModel: ViewModelType {
    struct Input {
        let load: Driver<Void>
        let like: Driver<Int>
        let willLastDisplay: Driver<Void>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let viewitList: Driver<[Viewit]>
        let isMoreLoading: Driver<Bool>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isLoadingRelay = CurrentValueRelay<Bool>(false)
        let viewitListRelay = CurrentValueRelay<[Viewit]>([])
        let errorMessageRelay = PassthroughRelay<String>()
        let isMoreLoadingRelay = CurrentValueRelay<Bool>(false)
        let isLastPageRelay = CurrentValueRelay<Bool>(false)
        
        let viewitList = viewitListRelay
            .removeDuplicates()
            .asDriver()
        
        input.load
            .handleEvents(receiveOutput: { _ in
                isLoadingRelay.send(true)
                isLastPageRelay.send(false)
            })
            .withUnretained(self)
            .flatMap { owner, _ in
                return owner.useCase.fetchViewitList(last: Constant.initialCursor)
                    .catch { error -> AnyPublisher<[Viewit], Never> in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just([])
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] viewitList in
                isLoadingRelay.send(false)
                isLastPageRelay.send(self?.isLastPage(viewitList) ?? false)
            })
            .sink { viewitListRelay.send($0) }
            .store(in: cancelBag)
        
        input.like
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .withUnretained(self)
            .flatMap { owner, index -> AnyPublisher<(Int, Viewit), Never> in
                let viewit = viewitListRelay.value[index]
                
                let publisher = viewit.like.status
                ? owner.useCase.unlinke(viewit: viewit)
                : owner.useCase.like(viewit: viewit)
                
                return publisher
                    .catch { error -> AnyPublisher<Viewit?, Never> in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .map { (index, $0) }
                    .eraseToAnyPublisher()
            }
            .sink { index, viewit in
                viewitListRelay.value[index] = viewit
            }
            .store(in: cancelBag)
        
        input.willLastDisplay
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !isMoreLoadingRelay.value && !isLastPageRelay.value && !viewitListRelay.value.isEmpty }
            .handleEvents(receiveOutput: { _ in
                isMoreLoadingRelay.send(true)
            })
            .compactMap { viewitListRelay.value.last?.id }
            .withUnretained(self)
            .flatMap { owner, lastItemID -> AnyPublisher<[Viewit], Never> in
                return owner.useCase.fetchViewitList(last: lastItemID)
                    .catch { error -> AnyPublisher<[Viewit], Never> in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just([])
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { _ in
                isMoreLoadingRelay.send(false)
            })
            .sink { viewitListRelay.send($0) }
            .store(in: cancelBag)
        
        return Output(
            isLoading: isLoadingRelay.asDriver(),
            viewitList: viewitList,
            isMoreLoading: isMoreLoadingRelay.asDriver(),
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}

private extension ViewitListViewModel {
    
    // MARK: - Helper Method

    func isLastPage(_ viewitList: [Viewit]) -> Bool {
        return viewitList.isEmpty || viewitList.count < Constant.defaultItemsCountPerPage
    }
    
    // MARK: - Constant
    
    enum Constant {
        static let initialCursor = -1
        static let defaultItemsCountPerPage: Int = 15
    }
}
