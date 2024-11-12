//
//  AmplitudeManager.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 9/30/24.
//

import Foundation

import AmplitudeSwift

final class AmplitudeManager {
    static let shared =  AmplitudeManager()
    
    private let amplitude: Amplitude

    private init() {
        amplitude = Amplitude(configuration: Configuration(apiKey: Config.amplitudeAppKey))
    }
    
    func trackEvent(tag: String) {
        amplitude.track(eventType: tag)
    }
}
