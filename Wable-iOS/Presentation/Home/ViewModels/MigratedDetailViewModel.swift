//
//  MigratedDetailViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/16/25.
//

import Foundation
import Combine

final class MigratedDetailViewModel {
    private var cursor: Int = -1
    private let service: HomeAPI
    private let feedData: HomeFeedDTO
    
    init(service: HomeAPI = HomeAPI.shared, feedData: HomeFeedDTO) {
        self.service = service
        self.feedData = feedData
    }
}

extension MigratedDetailViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        return Output()
    }
}
