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
    
    /// Logs a message with detailed contextual information.
    ///
    /// The log entry includes the log type's designation, the source file name (without extension), the line number, and the function name where the log was generated. Defaults for file, function, and line correspond to the call site.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - type: The category of the log (e.g., network, debug, error).
    ///   - file: The file path from which the log is invoked; defaults to the caller's file.
    ///   - function: The function name from which the log is invoked; defaults to the caller's function.
    ///   - line: The line number in the source file; defaults to the caller's line.
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
