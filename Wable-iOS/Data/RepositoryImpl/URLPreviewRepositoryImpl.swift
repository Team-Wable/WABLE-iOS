//
//  URLPreviewRepositoryImpl.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/4/25.
//

import Combine
import Foundation

import SwiftSoup

final class URLPreviewRepositoryImpl: URLPreviewRepository {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchPreview(url: URL) -> AnyPublisher<URLPreview, WableError> {
        return session.dataTaskPublisher(for: url)
            .mapError { _ -> WableError in
                return WableError.networkError
            }
            .tryMap { [weak self] data, response -> URLPreview in
                guard let self else {
                    throw WableError.unknownError
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw WableError.networkError
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    switch httpResponse.statusCode {
                    case 404:
                        throw WableError.notFoundContent
                    case 401:
                        throw WableError.unauthorizedToken
                    default:
                        throw WableError.networkError
                    }
                }
                
                guard let htmlString = String(data: data, encoding: .utf8) else {
                    throw WableError.validationException
                }
                
                return try parseHTML(htmlString, originalURL: url)
            }
            .mapError { error -> WableError in
                if let wableError = error as? WableError {
                    return wableError
                }
                return WableError.unknownError
            }
            .eraseToAnyPublisher()
    }
    
    // HTML 파싱 메서드
    private func parseHTML(_ html: String, originalURL: URL) throws -> URLPreview {
        do {
            let document = try SwiftSoup.parse(html)
            
            // 타이틀 추출
            let title: String
            if let titleElement = try document.select("meta[property=og:title]").first() {
                title = try titleElement.attr("content")
            } else if let titleTag = try document.select("title").first() {
                title = try titleTag.text()
            } else {
                title = "제목 없음"
            }
            
            // 이미지 URL 추출
            let imageURL: String
            if let imageElement = try document.select("meta[property=og:image]").first() {
                imageURL = try imageElement.attr("content")
            } else {
                // Open Graph 이미지가 없을 경우 첫 번째 이미지를 사용
                let images = try document.select("img")
                if let firstImage = images.first(), try !firstImage.attr("src").isEmpty {
                    let src = try firstImage.attr("src")
                    // 상대 경로를 절대 경로로 변환
                    if src.starts(with: "/") {
                        let baseUrl = URL(string: "\(originalURL.scheme!)://\(originalURL.host!)")!
                        imageURL = baseUrl.absoluteString + src
                    } else {
                        imageURL = src
                    }
                } else {
                    imageURL = ""
                }
            }
            
            // 사이트 이름 추출
            let siteName: String
            if let siteNameElement = try document.select("meta[property=og:site_name]").first() {
                siteName = try siteNameElement.attr("content")
            } else {
                // 사이트 이름이 없을 경우 도메인을 사용
                siteName = originalURL.host ?? "도메인 없음"
            }
            
            // 설명 추출
            let description: String
            if let descriptionElement = try document.select("meta[property=og:description]").first() {
                description = try descriptionElement.attr("content")
            } else if let descriptionElement = try document.select("meta[name=description]").first() {
                description = try descriptionElement.attr("content")
            } else {
                description = "설명 없음"
            }
            
            return URLPreview(
                title: title,
                urlString: originalURL.absoluteString,
                imageURLString: imageURL,
                siteName: siteName,
                description: description
            )
        } catch {
            WableLogger.log("HTML 파싱 에러: \(error.localizedDescription)", for: .error)
            throw WableError.unknownError
        }
    }
}
