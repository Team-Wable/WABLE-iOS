//
//  NextQuizInfoViewModel.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/26/25.
//

import Combine
import Foundation

import CombineMoya
import Moya

final class NextQuizInfoViewModel {
    @Injected private var userSessionRepository: UserSessionRepository
}

extension NextQuizInfoViewModel: ViewModelType {
    struct Input {
        let refreshDidTrigger: AnyPublisher<Void, Never>
    }

    struct Output {
        let remainTime: AnyPublisher<String, Never>
    }

    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let initialTime = Just(()).map { [weak self] _ -> String in
            self?.calculateRemainTime() ?? "00 : 00"
        }

        let refreshTime = input.refreshDidTrigger
            .withUnretained(self)
            .map { owner, _ in owner.calculateRemainTime() }
            .eraseToAnyPublisher()

        return Output(
            remainTime: initialTime.merge(with: refreshTime).eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension NextQuizInfoViewModel {
    func calculateRemainTime() -> String {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "KST") ?? TimeZone.current
        let now = Date()

        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        guard let currentHour = currentComponents.hour,
              let currentMinute = currentComponents.minute else {
            return "00 : 00"
        }

        let currentTotalMinutes = currentHour * 60 + currentMinute
        let remainMinutes = 1440 - currentTotalMinutes

        let hours = remainMinutes / 60
        let minutes = remainMinutes % 60

        return String(format: "%02d : %02d", hours, minutes)
    }
}
