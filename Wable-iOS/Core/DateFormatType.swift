import Foundation

// MARK: - DateFormatType

public enum DateFormatType: String {
    case fullDateTime = "yyyy-MM-dd HH:mm:ss"
    case dateTimeWithMinute = "yyyy-MM-dd HH:mm"
    case dashSeparatedDate = "yyyy-MM-dd"
    case dotSeparatedDate = "yyyy.MM.dd"
    case koreanDate = "yyyy년 MM월 dd일"
    case timeOnly = "HH:mm"
}