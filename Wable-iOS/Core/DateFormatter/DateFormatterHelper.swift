//
//  DateFormatterHelper.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 11/12/25.
//

import Foundation

public final class DateFormatterHelper {

    // MARK: - Properties

    private static let formatterCache = NSCache<NSString, DateFormatter>()
    private static let cacheQueue = DispatchQueue(label: "com.wable.dateFormatterCache")
}

// MARK: - Public Methods

public extension DateFormatterHelper {
    static func date(from string: String, type: DateFormatType) -> Date? {
        return cacheQueue.sync {
            let formatter = getFormatter(for: type)
            return formatter.date(from: string)
        }
    }
    
    static func string(from date: Date, type: DateFormatType) -> String {
        return cacheQueue.sync {
            let formatter = getFormatter(for: type)
            return formatter.string(from: date)
        }
    }
}

// MARK: - Private Methods

private extension DateFormatterHelper {
    private static func getFormatter(for type: DateFormatType) -> DateFormatter {
        let key = type.rawValue as NSString
        
        if let cached = formatterCache.object(forKey: key) {
            return cached
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = type.rawValue
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .current
        
        formatterCache.setObject(formatter, forKey: key)
        return formatter
    }
}
