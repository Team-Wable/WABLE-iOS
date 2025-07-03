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
        _ message: Any,
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
    
    static func network(
        _ message: Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, for: .network, file: file, function: function, line: line)
    }
    
    static func debug(
        _ message: Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, for: .debug, file: file, function: function, line: line)
    }
    
    static func error(
        _ message: Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, for: .error, file: file, function: function, line: line)
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
