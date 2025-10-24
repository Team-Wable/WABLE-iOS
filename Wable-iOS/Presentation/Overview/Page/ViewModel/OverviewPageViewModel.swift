//
//  OverviewPageViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/24/25.
//

import UIKit
import Combine

final class OverviewPageViewModel {
    let useCase: OverviewUseCase

    private let currentSegmentSubject = CurrentValueSubject<OverviewSegment, Never>(.gameSchedule)

    init(useCase: OverviewUseCase) {
        self.useCase = useCase
    }
}

extension OverviewPageViewModel: ViewModelType {
    struct Input {
        let segmentDidChange: AnyPublisher<OverviewSegment, Never>
        let pageSwipeCompleted: AnyPublisher<OverviewSegment, Never>
    }
    
    struct Output {
        let currentSegment: AnyPublisher<OverviewSegment, Never>
        let pagination: AnyPublisher<OverviewPageNavigation, Never>
        let showCurationBadge: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        input.pageSwipeCompleted
            .removeDuplicates()
            .sink { [weak self] segment in
                self?.currentSegmentSubject.send(segment)
            }
            .store(in: cancelBag)

        let initialPagination = OverviewPageNavigation(
            segment: currentSegmentSubject.value,
            direction: .forward
        )

        let pagination = input.segmentDidChange
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] segment in
                self?.currentSegmentSubject.send(segment)
            })
            .scan(initialPagination) { previous, newSegment in
                let direction: UIPageViewController.NavigationDirection = newSegment.rawValue > previous.segment.rawValue ? .forward : .reverse
                return OverviewPageNavigation(segment: newSegment, direction: direction)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        let currentSegment = currentSegmentSubject
            .dropFirst()
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] segment in
                self?.trackSegmentChangeEvent(for: segment)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let badgeUpdateOnCurationView = currentSegmentSubject
            .filter { $0 == .curation }
            .map { _ in false }
            .eraseToAnyPublisher()
        
        let showCurationBadge = Publishers.Merge(checkUnviewedCuration(), badgeUpdateOnCurationView)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(
            currentSegment: currentSegment, 
            pagination: pagination,
            showCurationBadge: showCurationBadge
        )
    }
}

// MARK: - Helper Methods

private extension OverviewPageViewModel {
    func trackSegmentChangeEvent(for segment: OverviewSegment) {
        switch segment {
        case .gameSchedule:
            AmplitudeManager.shared.trackEvent(tag: .clickGameschedule)
        case .teamRank:
            AmplitudeManager.shared.trackEvent(tag: .clickRanking)
        case .curation:
            AmplitudeManager.shared.trackEvent(tag: .clickNews)
        case .notice:
            AmplitudeManager.shared.trackEvent(tag: .clickAnnouncement)
        }
    }

    func checkUnviewedCuration() -> AnyPublisher<Bool, Never> {
        return useCase.checkUnviewedCuration()
            .catch { error -> AnyPublisher<Bool, Never> in
                WableLogger.log("Failed to check unviewed curation: \(error)", for: .error)
                return .just(false)
            }
            .eraseToAnyPublisher()
    }
}
