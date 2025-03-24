//
//  AmplitudeManager.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Foundation

import AmplitudeSwift

final class AmplitudeManager {
    static let shared =  AmplitudeManager()
    
    private let amplitude: Amplitude
    
    private init() {
        amplitude = Amplitude(configuration: Configuration(apiKey: Bundle.amplitudeAppKey))
    }
    
    func trackEvent(tag: String) {
        amplitude.track(eventType: tag)
    }
}
