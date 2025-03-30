//
//  WableLogger.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/13/25.
//

import Foundation
import OSLog

enum WableLogger {
    private static let logger = Logger(subsystem: "com.app.wable", category: "general")
    
    static func log(
        _ message: String,
        for type: LogType,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = ((file as NSString).lastPathComponent as NSString)
            .deletingPathExtension
        let formattedMessage = "[\(type.rawValue)/\(fileName)] \(line) line in \(function) ; \(message)"
        logger.debug("\(formattedMessage, privacy: .public)")
    }
}

// MARK: - LogType

extension WableLogger {
    enum LogType: String {
        case network = "🌐 Network"
        case debug = "🐞 Debug"
        case error = "❌ Error"
    }
}
