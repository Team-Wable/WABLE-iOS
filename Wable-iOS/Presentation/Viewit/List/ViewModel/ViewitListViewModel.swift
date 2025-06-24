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
    private let userSessionUseCase: FetchUserInformationUseCase
    
    private let loadingStateRelay = CurrentValueRelay<Bool>(false)
    private let viewitListRelay = CurrentValueRelay<[Viewit]>([])
    private let errorMessageRelay = PassthroughRelay<String>()
    private let moreLoadingStateRelay = CurrentValueRelay<Bool>(false)
    private let lastPageStateRelay = CurrentValueRelay<Bool>(false)
    private let indexMeatballDidTapRelay = CurrentValueRelay<Int>(0)
    private let reportStateRelay = CurrentValueRelay<Bool>(false)
    
    init(
        useCase: ViewitUseCase,
        likeUseCase: LikeViewitUseCase,
        reportUseCase: ReportViewitUseCase,
        checkUserRoleUseCase: CheckUserRoleUseCase,
        userSessionUseCase: FetchUserInformationUseCase
    ) {
        self.useCase = useCase
        self.likeUseCase = likeUseCase
        self.reportUseCase = reportUseCase
        self.checkUserRoleUseCase = checkUserRoleUseCase
        self.userSessionUseCase = userSessionUseCase
    }
}

extension ViewitListViewModel: ViewModelType {
    struct Input {
        let load: Driver<Void>
        let like: Driver<Int>
        let willLastDisplay: Driver<Void>
        let meatball: Driver<Int>
        let report: Driver<String>
        let delete: Driver<Void>
        let ban: Driver<Void>
        let profileDidTap: Driver<Int>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let viewitList: Driver<[Viewit]>
        let isMoreLoading: Driver<Bool>
        let userRole: Driver<UserRole>
        let isReportSuccess: Driver<Bool>
        let moveToProfile: Driver<Int?>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        bindLoad(input: input, cancelBag: cancelBag)
        bindLike(input: input, cancelBag: cancelBag)
        bindWillLastDisplay(input: input, cancelBag: cancelBag)
        bindReport(input: input, cancelBag: cancelBag)
        bindDelete(input: input, cancelBag: cancelBag)
        bindBan(input: input, cancelBag: cancelBag)
        
        return Output(
            isLoading: loadingStateRelay.asDriver(),
            viewitList: createViewitListPublisher(),
            isMoreLoading: moreLoadingStateRelay.asDriver(),
            userRole: createUserRolePublisher(input: input),
            isReportSuccess: reportStateRelay.asDriver(),
            moveToProfile: createMoveToProfilePublisher(input: input),
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}

private extension ViewitListViewModel {
    
    // MARK: - Binding Methods
    
    func bindLoad(input: Input, cancelBag: CancelBag) {
        let loadingEvents = input.load
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingStateRelay.send(true)
                self?.lastPageStateRelay.send(false)
            })
        
        let fetchPublisher: AnyPublisher<[Viewit], Never> = loadingEvents
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Viewit], Never> in
                return owner.fetchViewitList(last: IntegerLiterals.initialCursor)
            }
            .eraseToAnyPublisher()
        
        fetchPublisher
            .handleEvents(receiveOutput: { [weak self] viewitList in
                self?.loadingStateRelay.send(false)
                self?.lastPageStateRelay.send(self?.checkIsLastPage(viewitList) ?? false)
            })
            .sink { [weak self] in self?.viewitListRelay.send($0) }
            .store(in: cancelBag)
    }
    
    func bindLike(input: Input, cancelBag: CancelBag) {
        let debouncedLike: AnyPublisher<Int, Never> = input.like
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let indexPublisher: AnyPublisher<Int, Never> = debouncedLike
            .compactMap { [weak self] viewitID in
                return self?.viewitListRelay.value.firstIndex { $0.id == viewitID }
            }
            .eraseToAnyPublisher()
        
        indexPublisher
            .withUnretained(self)
            .flatMap { owner, index -> AnyPublisher<(Int, Viewit), Never> in
                let viewit = owner.viewitListRelay.value[index]
                let likePublisher: AnyPublisher<Viewit?, WableError> = viewit.like.status
                ? owner.likeUseCase.unlike(viewit: viewit)
                : owner.likeUseCase.like(viewit: viewit)
                
                return likePublisher
                    .catch { [weak owner] error -> AnyPublisher<Viewit?, Never> in
                        owner?.errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .compactMap { $0 }
                    .map { (index, $0) }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] index, viewit in
                self?.viewitListRelay.value[index] = viewit
            }
            .store(in: cancelBag)
    }
    
    func bindWillLastDisplay(input: Input, cancelBag: CancelBag) {
        let canLoadMore: AnyPublisher<Void, Never> = input.willLastDisplay
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !self.moreLoadingStateRelay.value &&
                !self.lastPageStateRelay.value &&
                !self.viewitListRelay.value.isEmpty
            }
            .eraseToAnyPublisher()
        
        let loadingEvents = canLoadMore
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.moreLoadingStateRelay.send(true)
            })
        
        let lastItemID: AnyPublisher<Int, Never> = loadingEvents
            .compactMap { [weak self] _ in self?.viewitListRelay.value.last?.id }
            .eraseToAnyPublisher()
        
        lastItemID
            .withUnretained(self)
            .flatMap { owner, lastItemID -> AnyPublisher<[Viewit], Never> in
                return owner.fetchViewitList(last: lastItemID)
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.moreLoadingStateRelay.send(false)
            })
            .sink { [weak self] in self?.viewitListRelay.value.append(contentsOf: $0) }
            .store(in: cancelBag)
    }
    
    func bindReport(input: Input, cancelBag: CancelBag) {
        let reportData: AnyPublisher<(Int, String), Never> = input.report
            .map { [weak self] message in
                (self?.indexMeatballDidTapRelay.value ?? 0, message)
            }
            .eraseToAnyPublisher()
        
        reportData
            .withUnretained(self)
            .flatMap { owner, data -> AnyPublisher<Viewit?, Never> in
                let (index, message) = data
                let viewit = owner.viewitListRelay.value[index]
                return owner.reportUseCase.report(viewit: viewit, message: message)
                    .catch { [weak owner] error -> AnyPublisher<Viewit?, Never>  in
                        owner?.errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .sink { [weak self] _ in self?.reportStateRelay.send(true) }
            .store(in: cancelBag)
    }
    
    func bindDelete(input: Input, cancelBag: CancelBag) {
        let indexPublisher: AnyPublisher<Int, Never> = input.delete
            .map { [weak self] _ in self?.indexMeatballDidTapRelay.value ?? 0 }
            .eraseToAnyPublisher()
        
        indexPublisher
            .withUnretained(self)
            .flatMap { owner, index -> AnyPublisher<(Int, Viewit?), Never> in
                let viewit = owner.viewitListRelay.value[index]
                return owner.useCase.delete(viewit: viewit)
                    .catch { [weak owner] error -> AnyPublisher<Viewit?, Never>  in
                        owner?.errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .map { (index, $0) }
                    .eraseToAnyPublisher()
            }
            .compactMap { index, viewit in viewit.map { (index, $0) } }
            .sink { [weak self] index, _ in
                self?.viewitListRelay.value.remove(at: index)
            }
            .store(in: cancelBag)
    }
    
    func bindBan(input: Input, cancelBag: CancelBag) {
        let indexPublisher: AnyPublisher<Int, Never> = input.ban
            .map { [weak self] _ in self?.indexMeatballDidTapRelay.value ?? 0 }
            .eraseToAnyPublisher()
        
        let banPublisher: AnyPublisher<[Viewit], Never> = indexPublisher
            .withUnretained(self)
            .flatMap { owner, index -> AnyPublisher<Viewit?, Never> in
                let viewit = owner.viewitListRelay.value[index]
                return owner.reportUseCase.ban(viewit: viewit)
                    .catch { [weak owner] error -> AnyPublisher<Viewit?, Never>  in
                        owner?.errorMessageRelay.send(error.localizedDescription)
                        return .just(nil)
                    }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[Viewit], Never> in
                return owner.fetchViewitList(last: IntegerLiterals.initialCursor)
            }
            .eraseToAnyPublisher()
        
        banPublisher
            .sink { [weak self] in self?.viewitListRelay.send($0) }
            .store(in: cancelBag)
    }
    
    // MARK: - Publisher Creation Method
    
    func createViewitListPublisher() -> AnyPublisher<[Viewit], Never> {
        return viewitListRelay
            .removeDuplicates()
            .asDriver()
    }
    
    func createUserRolePublisher(input: Input) -> AnyPublisher<UserRole, Never> {
        let indexPublisher: AnyPublisher<Int, Never> = input.meatball
            .compactMap { [weak self] viewitID in
                return self?.viewitListRelay.value.firstIndex { $0.id == viewitID }
            }
            .handleEvents(receiveOutput: { [weak self] index in
                self?.indexMeatballDidTapRelay.send(index)
            })
            .eraseToAnyPublisher()
        
        return indexPublisher
            .compactMap { [weak self] index in
                let userID = self?.viewitListRelay.value[index].userID ?? 0
                return self?.checkUserRoleUseCase.execute(userID: userID)
            }
            .asDriver()
    }
    
    func createMoveToProfilePublisher(input: Input) -> AnyPublisher<Int?, Never> {
        let userIDPairs: AnyPublisher<(Int, Int)?, Never> = input.profileDidTap
            .withUnretained(self)
            .compactMap { owner, userID -> (Int, Int)? in
                guard let activeUserID = owner.userSessionUseCase.fetchActiveUserID() else {
                    return nil
                }
                return (activeUserID, userID)
            }
            .eraseToAnyPublisher()
        
        return userIDPairs
            .map { pairs -> Int? in
                guard let (activeUserID, userID) = pairs else { return nil }
                return activeUserID == userID ? .none : userID
            }
            .asDriver()
    }
    
    // MARK: - Helper Methods
    
    func fetchViewitList(last: Int) -> AnyPublisher<[Viewit], Never> {
        return useCase.fetchViewitList(last: last)
            .catch { [weak self] error -> AnyPublisher<[Viewit], Never> in
                self?.errorMessageRelay.send(error.localizedDescription)
                return .just([])
            }
            .eraseToAnyPublisher()
    }
    
    func checkIsLastPage(_ viewitList: [Viewit]) -> Bool {
        return viewitList.isEmpty || viewitList.count < IntegerLiterals.defaultCountPerPage
    }
}
