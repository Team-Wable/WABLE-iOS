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
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let viewitList: Driver<[Viewit]>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isLoadingRelay = CurrentValueRelay<Bool>(false)
        let viewitListRelay = CurrentValueRelay<[Viewit]>([])
        let errorMessageRelay = PassthroughRelay<String>()
        
        let viewitList = viewitListRelay
            .removeDuplicates()
            .asDriver()
        
        input.load
            .handleEvents(receiveOutput: { _ in isLoadingRelay.send(true) })
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Viewit], Never> in
                return owner.useCase.fetchViewitList(last: Constant.initialCursor)
                    .catch { error -> AnyPublisher<[Viewit], Never> in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just([])
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { _ in isLoadingRelay.send(false) })
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
        
        return Output(
            isLoading: isLoadingRelay.asDriver(),
            viewitList: viewitList,
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}

private extension ViewitListViewModel {
    
    // MARK: - Constant
    
    enum Constant {
        static let initialCursor = -1
    }
}
