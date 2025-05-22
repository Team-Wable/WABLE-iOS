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
    private let likeUseCase: LikeViewitUseCase
    private let reportUseCase: ReportViewitUseCase
    private let checkUserRoleUseCase: CheckUserRoleUseCase
    
    init(
        useCase: ViewitUseCase,
        likeUseCase: LikeViewitUseCase,
        reportUseCase: ReportViewitUseCase,
        checkUserRoleUseCase: CheckUserRoleUseCase
    ) {
        self.useCase = useCase
        self.likeUseCase = likeUseCase
        self.reportUseCase = reportUseCase
        self.checkUserRoleUseCase = checkUserRoleUseCase
    }
}

extension ViewitListViewModel: ViewModelType {
    struct Input {
        let load: Driver<Void>
        let like: Driver<Int>
        let willLastDisplay: Driver<Void>
        let meatball: Driver<Int>
        let bottomSheetAction: Driver<ViewitBottomSheetActionKind>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let viewitList: Driver<[Viewit]>
        let isMoreLoading: Driver<Bool>
        let userRole: Driver<UserRole>
        let isReportSuccess: Driver<Bool>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isLoadingRelay = CurrentValueRelay<Bool>(false)
        let viewitListRelay = CurrentValueRelay<[Viewit]>([])
        let errorMessageRelay = PassthroughRelay<String>()
        let isMoreLoadingRelay = CurrentValueRelay<Bool>(false)
        let isLastPageRelay = CurrentValueRelay<Bool>(false)
        let indexMeatballDidTapRelay = CurrentValueRelay<Int>(0)
        let isReportSuccess = CurrentValueRelay<Bool>(false)
        
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
            .compactMap { viewitID in
                return viewitListRelay.value.firstIndex { $0.id == viewitID }
            }
            .withUnretained(self)
            .flatMap { owner, index -> AnyPublisher<(Int, Viewit), Never> in
                let viewit = viewitListRelay.value[index]
                
                let publisher = viewit.like.status
                ? owner.likeUseCase.unlike(viewit: viewit)
                : owner.likeUseCase.like(viewit: viewit)
                
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
            .sink { viewitListRelay.value.append(contentsOf: $0) }
            .store(in: cancelBag)
        
        let userRole = input.meatball
            .compactMap { viewitID in
                return viewitListRelay.value.firstIndex { $0.id == viewitID }
            }
            .handleEvents(receiveOutput: { index in
                indexMeatballDidTapRelay.send(index)
            })
            .compactMap { [weak self] index in
                let userID = viewitListRelay.value[index].userID
                return self?.checkUserRoleUseCase.execute(userID: userID)
            }
            .asDriver()
        
        input.bottomSheetAction
            .filter { $0 == .ban }
            .map { _ in indexMeatballDidTapRelay.value }
            .withUnretained(self)
            .flatMap { owner, index in
                let viewit = viewitListRelay.value[index]
                return owner.reportUseCase.ban(viewit: viewit)
                    .catch { error -> AnyPublisher<Viewit?, Never>  in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .withUnretained(self)
                    .flatMap { owner, _ -> AnyPublisher<[Viewit], Never> in
                        return owner.useCase.fetchViewitList(last: Constant.initialCursor)
                            .catch { error -> AnyPublisher<[Viewit], Never> in
                                errorMessageRelay.send(error.localizedDescription)
                                return .just([])
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { viewitListRelay.send($0) }
            .store(in: cancelBag)
        
        input.bottomSheetAction
            .filter { $0 == .delete }
            .map { _ in indexMeatballDidTapRelay.value }
            .withUnretained(self)
            .flatMap { owner, index in
                let viewit = viewitListRelay.value[index]
                return owner.useCase.delete(viewit: viewit)
                    .catch { error -> AnyPublisher<Viewit?, Never>  in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .map { (index, $0) }
                    .eraseToAnyPublisher()
            }
            .sink { index, viewit in
                viewitListRelay.value.remove(at: index)
            }
            .store(in: cancelBag)
        
        input.bottomSheetAction
            .filter { $0 == .report }
            .map { _ in indexMeatballDidTapRelay.value }
            .withUnretained(self)
            .flatMap { owner, index in
                let viewit = viewitListRelay.value[index]
                return owner.reportUseCase.report(viewit: viewit)
                    .catch { error -> AnyPublisher<Viewit?, Never>  in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .map { (index, $0) }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { _ in
                isReportSuccess.send(true)
            })
            .sink { index, viewit in
                var viewitList = viewitListRelay.value
                viewitList.remove(at: index)
                viewitListRelay.send(viewitList)
            }
            .store(in: cancelBag)
        
        return Output(
            isLoading: isLoadingRelay.asDriver(),
            viewitList: viewitList,
            isMoreLoading: isMoreLoadingRelay.asDriver(),
            userRole: userRole,
            isReportSuccess: isReportSuccess.asDriver(),
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
